-- Drop Statements
DROP TABLE employee CASCADE CONSTRAINTS PURGE;
DROP TABLE part CASCADE CONSTRAINTS PURGE;
DROP TABLE carservice CASCADE CONSTRAINTS PURGE;
DROP TABLE preference CASCADE CONSTRAINTS PURGE;
DROP TABLE customer CASCADE CONSTRAINTS PURGE;
DROP TABLE salevehicle CASCADE CONSTRAINTS PURGE;
DROP TABLE servicevehicle CASCADE CONSTRAINTS PURGE;
DROP TABLE service_invoice CASCADE CONSTRAINTS PURGE;
DROP TABLE purchase_invoice CASCADE CONSTRAINTS PURGE;
DROP TABLE sales_invoice CASCADE CONSTRAINTS PURGE;
DROP TABLE carseller CASCADE CONSTRAINTS PURGE;
DROP TABLE service_list CASCADE CONSTRAINTS PURGE;
DROP TABLE part_list CASCADE CONSTRAINTS PURGE;

-- Create Tables
CREATE TABLE employee
(
Employee_id     NUMBER(4)        CONSTRAINT emp_id_pk PRIMARY KEY,
First_name      VARCHAR2(15)    NOT NULL,
Last_name       VARCHAR2(15)    NOT NULL,
Employee_street VARCHAR2(40)    NOT NULL,
Employee_city   VARCHAR2(15)    NOT NULL,
Employee_state  CHAR(2)         DEFAULT 'CA' NOT NULL,
Employee_zip    VARCHAR2(5)     NOT NULL,
Employee_phone  VARCHAR2(12)    CONSTRAINT emp_phone_uk UNIQUE,
Employee_email  VARCHAR2(35)    CONSTRAINT emp_em_uk UNIQUE,
Employee_title  VARCHAR2(25)    NOT NULL,
Hire_date   DATE,
Manager_id      NUMBER(4),
Department_type CHAR(2)     CONSTRAINT dep_type_ck CHECK (Department_type IN ('SV','AC','SA')),
Commission_pct  NUMBER(3,2)     CONSTRAINT emp_comm_ck CHECK (commission_pct>0.20 AND Commission_pct<0.30),
CONSTRAINT emp_id_ck CHECK (employee_id>=1000),
CONSTRAINT emp_mnid_fk FOREIGN KEY (Manager_id) REFERENCES employee(employee_id),
CONSTRAINT emp_type_ck CHECK ((department_type = 'SV' AND Commission_pct IS NULL) 
OR (department_type = 'AC' AND Commission_pct IS NULL) 
OR (department_type = 'SA' AND Commission_pct IS NOT NULL))
);

CREATE TABLE carservice
(
Service_code        VARCHAR2(20)       CONSTRAINT sv_code_pk PRIMARY KEY,
Service_desc        VARCHAR2(25)        NOT NULL,
Service_cost     NUMBER(6,2)         CONSTRAINT sv_cost_ck CHECK(service_cost>0) NOT NULL,
Service_price     NUMBER(6,2)        NOT NULL,
Service_months     NUMBER(2),       CONSTRAINT sv_month_ck CHECK (service_months>0),
Service_mileage     NUMBER(6),       CONSTRAINT sv_mile_ck CHECK (service_mileage>0),
CONSTRAINT sv_price_ck CHECK (service_price>service_cost)
);

CREATE TABLE part
(
Part_code       VARCHAR2(20) CONSTRAINT pt_code_pk PRIMARY KEY,
Part_desc       VARCHAR2(25)    NOT NULL,
Part_cost       NUMBER(6,2)     CONSTRAINT pt_cost_ck CHECK (part_cost>0) NOT NULL,
Part_price      NUMBER(6,2)     NOT NULL,
CONSTRAINT pt_price_ck CHECK (part_price>part_cost)
);

CREATE TABLE customer
(
Customer_id     VARCHAR2(8)     CONSTRAINT cust_id_pk PRIMARY KEY,
First_name      VARCHAR2(15)    NOT NULL,
Last_name       VARCHAR2(15)    NOT NULL,
Customer_street VARCHAR2(25)    NOT NULL,
Customer_city   VARCHAR2(15)    NOT NULL,
Customer_state  CHAR(2)         DEFAULT 'CA' NOT NULL,
Customer_zip    VARCHAR2(5)     NOT NULL,
Customer_phone  VARCHAR2(12)    CONSTRAINT cust_phone_uk UNIQUE NOT NULL,
Customer_email  VARCHAR2(35)    CONSTRAINT cust_em_uk UNIQUE NOT NULL
);
 
CREATE TABLE preference
(
Pref_id         VARCHAR(8)  CONSTRAINT pref_id_pk PRIMARY KEY,
Customer_id     VARCHAR2(8) NOT NULL,
Pref_make       VARCHAR2(10) NOT NULL,
Pref_model      VARCHAR2(20) NOT NULL,
Pref_year       NUMBER(4),
Pref_desc	VARCHAR2(20),
Start_date      DATE DEFAULT SYSDATE NOT NULL,
End_date        DATE,
CONSTRAINT pref_end_ck CHECK(end_date>start_date),
CONSTRAINT pref_cust_fk FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE servicevehicle
    (
    Vehicle_VIN       		    VARCHAR2(6)     	    NOT NULL CONSTRAINT is_vin_pk PRIMARY KEY,
    Vehicle_Year                NUMBER(4)               NOT NULL,
    Vehicle_Make                VARCHAR2(20)            NOT NULL,
    Vehicle_Model               VARCHAR2(20)            NOT NULL,
    Vehicle_Mileage             NUMBER(6)               NOT NULL,
    Customer_ID                 VARCHAR2(8)             NOT NULL,
    CONSTRAINT is_cid_fk    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
    );

CREATE TABLE carseller
    (
    Seller_ID          	 	   VARCHAR2(10)       	    NOT NULL CONSTRAINT auto_co_pk PRIMARY KEY,
    Seller_Name        		   VARCHAR2(20),
    Seller_Contact        	   VARCHAR2(15)      	    NOT NULL,
    Seller_Street              VARCHAR2(30)     	    NOT NULL,
    Seller_City                VARCHAR2(20)     	    NOT NULL,
    Seller_State               CHAR(2)            	    NOT NULL,
    Seller_Zip_Code            NUMBER(5)          	    NOT NULL,
    Seller_Phone               VARCHAR2(15)         	NOT NULL,
    Seller_Fax                 VARCHAR2(15)
    );

CREATE TABLE salevehicle
    (
    Vehicle_VIN                 VARCHAR2(6)             NOT NULL CONSTRAINT fs_vin_pk PRIMARY KEY,
    Vehicle_Year                NUMBER(4)               NOT NULL CONSTRAINT fs_year_ck CHECK(Vehicle_Year > 0),
    Vehicle_Make                VARCHAR2(20)            NOT NULL,
    Vehicle_Model               VARCHAR2(20)            NOT NULL,
    Vehicle_Mileage             NUMBER(6)               NOT NULL CONSTRAINT fs_miles_ck CHECK(Vehicle_Mileage > 0),
    Exterior_Color              VARCHAR2(10)            NOT NULL,
    Trim                        VARCHAR2(20),
    Condition       	        VARCHAR2(10)            NOT NULL,
    Status                      VARCHAR2(10)            NOT NULL CHECK(Status IN ('FORSALE', 'SOLD', 'TRADEIN')),
    Purchase_Price              NUMBER(15,2)            CONSTRAINT fs_pur_ck CHECK(purchase_price > 0),
    List_Price                  NUMBER(15,2)            CONSTRAINT fs_list_ck CHECK(list_price > 0),
    Trade_In_Allowance          NUMBER(15,2)            CONSTRAINT fs_all_ck CHECK(trade_in_allowance > 0),
    Seller_ID                   VARCHAR2(10),
    Customer_ID                 VARCHAR2(8),
    CONSTRAINT fs_vid_fk    FOREIGN KEY (Seller_ID) REFERENCES carseller(Seller_ID),
    CONSTRAINT fs_cid_fk    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CONSTRAINT salev_stat_ck CHECK(
                            (Status = 'FORSALE'
                            AND purchase_price IS NOT NULL
                            AND list_price IS NOT NULL
                            AND Customer_ID IS NULL)
                            OR
                            (Status = 'TRADEIN'
                            AND purchase_price IS NULL
                            AND list_price IS NULL
                            AND trade_in_allowance IS NOT NULL
                            AND Customer_ID IS NOT NULL)
                            OR
                            (Status = 'SOLD'
                            AND purchase_price IS NOT NULL
                            AND list_price IS NOT NULL
                            AND trade_in_allowance IS NULL
                            AND Customer_ID IS NOT NULL)
                            )
);

CREATE TABLE service_invoice
    (
    service_invoice_id          NUMBER(7)               CONSTRAINT service_invoice_sid_pk PRIMARY KEY,
    Employee_id                 NUMBER(4)               NOT NULL,
    manager_id                  NUMBER(4),
    Customer_id                 VARCHAR2(8)             NOT NULL,
    Vehicle_VIN                 VARCHAR2(6)             NOT NULL,
    date_serviced               DATE                    NOT NULL,
    misc_charge                 NUMBER(7),
    Taxes				        NUMBER(5,4)             NOT NULL,
    CONSTRAINT emp_service_eid_fk FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT emp_service_mnid_fk FOREIGN KEY (manager_id) REFERENCES employee(employee_id),
    CONSTRAINT customer_service_cid_fk FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT ServiceVehicle_sid_fk FOREIGN KEY (Vehicle_VIN) REFERENCES ServiceVehicle(Vehicle_VIN)
    );
    
CREATE TABLE purchase_invoice
    (
    purchase_invoice_id         NUMBER(7)               CONSTRAINT purchase_invoice_pid_pk PRIMARY KEY,
    manager_id                  NUMBER(4),
    Seller_id                   VARCHAR2(10),
    date_purchased              DATE                    NOT NULL,
    purchase_shipping           NUMBER(7, 2),
    purchase_taxes              NUMBER(5,4)             NOT NULL,
    CONSTRAINT emp_purchase_mnid_fk FOREIGN KEY (manager_id) REFERENCES employee(employee_id),
    CONSTRAINT CarSeller_purchase_vid_fk FOREIGN KEY (Seller_id) REFERENCES CarSeller(Seller_id)
    );

CREATE TABLE sales_invoice
    (
    sales_invoice_id            NUMBER(7)               CONSTRAINT sales_invoice_sid_pk PRIMARY KEY,
    Employee_id                 NUMBER(4)               NOT NULL,
    manager_id                  NUMBER(4),
    Customer_id                 VARCHAR2(8)             NOT NULL,
    date_sold                   DATE                    NOT NULL,
    terms                       VARCHAR2(15)            NOT NULL,
    sales_shipping              NUMBER(7, 2),
    sales_discount              NUMBER(7,2),
    sales_taxes                 NUMBER(5,4)             NOT NULL,
    sales_misc                  NUMBER(7,2),
    Sold_Vehicle_VIN            VARCHAR2(6)             NOT NULL,
    TradeIn_Vehicle_VIN         VARCHAR2(6),
    CONSTRAINT emp_sales_eid_fk FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT emp_sales_mnid_fk FOREIGN KEY (manager_id) REFERENCES employee(employee_id),
    CONSTRAINT customer_sales_cid_fk FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT salevehicle_sVIN_svin_fk FOREIGN KEY (sold_vehicle_VIN) REFERENCES salevehicle(vehicle_VIN),
    CONSTRAINT salevehicle_tVIN_svin_fk FOREIGN KEY (tradein_vehicle_VIN) REFERENCES salevehicle(vehicle_VIN)
    );
 
        CREATE TABLE service_list
        (Service_code           VARCHAR2(20),
        SERVICE_INVOICE_ID      NUMBER(7,0),
        CONSTRAINT svlist_svcode_fk FOREIGN KEY (service_code) REFERENCES carservice(service_code),
        CONSTRAINT svlist_svinv_fk FOREIGN KEY (SERVICE_INVOICE_ID) REFERENCES service_invoice(SERVICE_INVOICE_ID),
        CONSTRAINT svlist_pk PRIMARY KEY (service_code, service_invoice_id)
        );

        CREATE TABLE part_list
        (part_code           VARCHAR2(20),
        SERVICE_INVOICE_ID      NUMBER(7,0),
        CONSTRAINT plist_partcode_fk FOREIGN KEY (part_code) REFERENCES part(part_code),
        CONSTRAINT plist_svinv_fk FOREIGN KEY (SERVICE_INVOICE_ID) REFERENCES service_invoice(SERVICE_INVOICE_ID),
        CONSTRAINT plist_pk PRIMARY KEY (part_code, service_invoice_id)
        );

-- Insert Data
INSERT INTO customer VALUES (1234, 'Kevin', 'Chang', '2120 Higuera Street', 'San Luis Obispo', DEFAULT, '92010', '7583928475', 'kevkevkev@calpoly.edu' );
INSERT INTO customer VALUES (1456, 'Amy', 'Ru', '2120 Higuera Street', 'San Luis Obispo', DEFAULT, '92010', '8583928475', 'amyamyamy@calpoly.edu' );
INSERT INTO customer VALUES (1785, 'Han', 'Tran', '2121 Higuera Street', 'San Luis Obispo', DEFAULT, '92010', '8584059841', 'hanhanhan@calpoly.edu' );
INSERT INTO customer VALUES (8294, 'Barry', 'Floyd', '839 Higuera St', 'San Luis Obispo',DEFAULT, '93401', '8055420105', 'barbarbar@calpoly.edu' );
INSERT INTO customer VALUES (1875, 'Jennifer', 'Lopez', '858 Foothill Blvd', 'San Luis Obispo', DEFAULT, '93405', '8054392510', 'jenjenjen@calpoly.edu' );
INSERT INTO customer VALUES (8523, 'Miley', 'Cyrus', '1 Grand Avenue', 'San Luis Obispo', 'CA', '93410', '8057561111', 'polpolpol@calpoly.edu' );
INSERT INTO customer VALUES (1954, 'Jack', 'Harlow', '793F Foothill Blvd', 'San Luis Obispo', 'CA', '93405', '8057829766', 'jacjacjac@calpoly.edu' );
INSERT INTO customer VALUES (2435, 'Hannah', 'Montana', '350 High St', 'San Luis Obispo', 'CA', '93401', '8055414738', 'nahnahnah@calpoly.edu' );
INSERT INTO customer VALUES (4619, 'Michelle', 'Obama', '2900 Broad St', 'San Luis Obispo', 'CA', '93401', '8052002978', 'obaobaoba@calpoly.edu' );
INSERT INTO customer VALUES (2928, 'Kamala', 'Harris', '1121 Broad St', 'San Luis Obispo', 'CA', '93401', '8055455401', 'harharhar@calpoly.edu' );

INSERT INTO preference VALUES ('1234A', 1234, 'Porsche', '718 Cayman', '2000',NULL, DEFAULT, '01/01/2021' );
INSERT INTO preference VALUES ('1234B', 1234, 'Toyota', 'Camry Hybrid', '2018',NULL, DEFAULT, '02/14/2021' );
INSERT INTO preference VALUES ('1234C', 1234, 'Chevrolet', 'Impala', '2017','Leather seats', DEFAULT, NULL );
INSERT INTO preference VALUES ('4619A', 4619, 'Lincoln', 'MKZ', '2017','Hybrid', '10/05/2020', '01/15/2021' );
INSERT INTO preference VALUES ('4619B', 4619, 'BMW', 'X3', '2018','Grey', '10/05/2020', '01/15/2021' );
INSERT INTO preference VALUES ('1785A', 1785, 'Porsche', '718 Boxster', '2010','All black','10/20/2020', '12/31/2020' );
INSERT INTO preference VALUES ('1456A', 1456, 'Volkswagen', 'Getta GLI', '2020',NULL, '10/31/2020', '12/31/2020' );
INSERT INTO preference VALUES ('8523A', 8523, 'Porsche', '718 Spyder', '2012','Red or white', '09/05/2019', '09/05/2020' );

INSERT INTO employee VALUES (1000, 'Larry', 'Margaria', '90 Rich Ave', 'San Luis Obispo', DEFAULT, '93405', '8053456789', 'lmargaria@slovintage.com', 'Owner/Manager', '08/08/2005', NULL, NULL, NULL);

INSERT INTO employee VALUES (1021, 'Jim', 'Kaney', '91 Big 4 Ave', 'San Luis Obispo', DEFAULT, '93405', '8055643245', 'jkaney@slovintage.com', 'Accounting Manager', '04/03/2008', 1000, 'AC', NULL);
INSERT INTO employee VALUES (1098, 'Steve', 'Euro', '100 Money Ave', 'San Luis Obispo', DEFAULT, '93405', '8053565245', 'seuro@slovintage.com', 'Cashier', '02/14/2017', 1021, 'AC', NULL);
INSERT INTO employee VALUES (1099, 'Alice', 'Credit', '125 Debit Ave', 'San Luis Obispo', 'CA', '93405', '8059324566', 'acredit@slovintage.com', 'Bookkeeper', '12/24/2018', 1021, 'AC', NULL);

INSERT INTO employee VALUES (1026, 'Norm', 'Allen', '875 Please People Blvd', 'San Luis Obispo', 'CA', '93405', '8052345612', 'nallen@slovintage.com', 'Service Manager', '02/19/2013', 1000, 'SV', NULL);
INSERT INTO employee VALUES (1045, 'Alan', 'Wrench', '835 Please Norm Blvd', 'San Luis Obispo', 'CA', '93405', '8059871236', 'awrench@slovintage.com', 'Service Worker', '01/05/2018', 1026, 'SV', NULL);
INSERT INTO employee VALUES (1036, 'Woody', 'Apple', '835 Orange St', 'San Luis Obispo', 'CA', '93405', '8059871242', 'wapple@slovintage.com', 'Service Worker', '01/14/2016', 1026, 'SV', NULL);
INSERT INTO employee VALUES (1100, 'Sherry', 'Sophomore', '243 Unpaid St', 'San Luis Obispo', 'CA', '93405', '8055562124', 'ssophomore@slovintage.com', 'Cal Poly Intern', '10/05/2020', 1036, 'SV', NULL);

INSERT INTO employee VALUES (1030, 'Mary', 'Long', '1378 Commission St', 'San Luis Obispo', 'CA', '93405', '8052341753', 'mlong@slovintage.com', 'Sales Manager', '12/20/2011', 1000, 'SA', 0.25);
INSERT INTO employee VALUES (1071, 'Adam', 'Packer', '284 Tired St', 'San Luis Obispo', 'CA', '93405', '8052341724', 'apacker@slovintage.com', 'Salesperson', '02/28/2017', 1030, 'SA', 0.22);
INSERT INTO employee VALUES (1079, 'Larry', 'Jones', '123 Boring St', 'San Luis Obispo', 'CA', '93405', '8052353724', 'ljones@slovintage.com', 'Salesperson', '03/15/2017', 1030, 'SA', 0.24);

INSERT INTO carservice VALUES ('OILCHG','Oil Change',9.95, 10.95, 6, 6000);
INSERT INTO carservice VALUES ('TIREROTATE','Tire Rotation',6.95, 9.95, 12, 12000);
INSERT INTO carservice VALUES ('FLUIDS','Fluid Replacement',29.95, 49.96, 30, 30000);
INSERT INTO carservice VALUES ('TUNEUPBASICS','Basic Engine tune up',69.95, 149.95, 18, 18000);
INSERT INTO carservice VALUES ('MULTIPOINTINTSP','Multi-Point Inspection',29.95, 59.95, 6, 6000);
INSERT INTO carservice VALUES ('BRAKEINSPECT','Brake Inspection', 30.95, 70.50, 12, 20000);
INSERT INTO carservice VALUES ('BATTERYREPLACE','Battery Replacement', 30.00, 50.00, 30, 30000);

INSERT INTO part VALUES ('OIL10W30','Oil 10W30', 2.79, 3.95);
INSERT INTO part VALUES ('OILFILTER','Oil Filter', 6.95, 11.95);
INSERT INTO part VALUES ('WINSHIELDFLUID','Windshield Fluid', 2.96, 4.95);
INSERT INTO part VALUES ('SPARKPLUG4','Spark Plug Set (4)', 9.95, 19.95);
INSERT INTO part VALUES ('AIRFILTER','Air Filter', 3.95, 8.95);
INSERT INTO part VALUES ('BATTERY','Lead-acid AGM Battery', 20.75, 28.75);
INSERT INTO part VALUES ('HUBCAP','15 INCH HUB CAPS (4)', 166.50, 200.95);
-- Car Sellers
    INSERT INTO carseller
    VALUES (91563, 'Barry Good Cars', 'Barry Floyd', '123 Higuera St.', 'San Luis Obispo', 'CA', 93401, '(805) 457-9823', '(805) 457-8801');
    
    INSERT INTO carseller
    VALUES (92234, 'Wheel n Deal', 'Howie Mandel', '5106 Dealer Way', 'Los Angeles', 'CA', 92310, '(626) 715-8275', '(626) 715-7770');

    INSERT INTO carseller
    VALUES (92335, 'Cars Land', 'Guido Sanchez', '314 Magic Way', 'Anaheim', 'CA', 92830, '(714) 880-7171', '(714) 880-7172');

    INSERT INTO carseller
    VALUES (91392, 'Classic Wheels', 'Tim Cook', '415 Apple Rd', 'Cupertino', 'CA', 95014, '(415) 321-4145', '(415) 321-4140');

    INSERT INTO carseller
    VALUES (93350, 'Automatic Mechanic', 'Bill Gates', '500 Billion Way', 'Los Osos', 'CA', 93402, '(805) 550-6072', '(805) 550-6070');

    INSERT INTO carseller
    VALUES (00001, 'SLO Vintage Auto', 'Larry Margaria', '10000 Los Valley Road', 'San Luis Obispo', 'CA', 93408, '(805) 123-1234', '(805) 123-1235');

-- Buying a New Vehicle from a Car Seller
    INSERT INTO salevehicle VALUES ('1YVHP8', 1967, 'Chevrolet', 'Corvette', 21310, 'Red', NULL, 'Good', 'FORSALE', 155000.00, 170000.00, NULL, 91392, NULL);
    INSERT INTO purchase_invoice VALUES (009, NULL, 91392, '09-09-2020', 199.99, 0.0725);
    UPDATE purchase_invoice SET manager_id = 1000 WHERE purchase_invoice_id = 009;

    INSERT INTO salevehicle VALUES ('4T1BG2', 1974, 'Porsche', '911', 19523, 'White', '2 Door Coupe', 'Excellent', 'FORSALE', 40000.00, 70000.50, NULL, 92234, NULL);
    INSERT INTO purchase_invoice VALUES (007, 1000, 92234, '07-07-2020', 200.77, 0.0725);
    UPDATE purchase_invoice SET manager_id = 1000 WHERE purchase_invoice_id = 007;

    INSERT INTO salevehicle VALUES ('1G2ZJ5', 1975, 'BMW', '3.0 CSL', 18720, 'Black', '2 Door Coupe', 'Excellent', 'FORSALE', 100000.00, 131600.00, NULL, 92335, NULL);
    INSERT INTO purchase_invoice VALUES (008, 1000, 92335, SYSDATE, 284.88, 0.0725);
    UPDATE purchase_invoice SET manager_id = 1000 WHERE purchase_invoice_id = 008;

    INSERT INTO salevehicle VALUES ('1GNCS1', 1965, 'Jaguar', 'E-Type', 22400, 'Blue', 'Fixed Head Coupe', 'Good', 'FORSALE', 150000.00, 187000.00, NULL, 93350, NULL);
    INSERT INTO purchase_invoice VALUES (010, 1000, 93350, '10-10-2020', 310.10, 0.0725);
    UPDATE purchase_invoice SET manager_id = 1000 WHERE purchase_invoice_id = 010;

    INSERT INTO salevehicle VALUES ('1GKEV2', 1966, 'Lamborghini', 'Miura', 20560, 'Green', '2 Door Coupe', 'Excellent', 'FORSALE', 125000.00, 157600.00, NULL, 91563, NULL);
    INSERT INTO purchase_invoice VALUES (006, 1000, 91563, '06-06-2020', 100.00, 0.0725);
    UPDATE purchase_invoice SET manager_id = 1000 WHERE purchase_invoice_id = 006;


-- Selling a Vehicle 

    -- Vehicles Purchased by Customers
        INSERT INTO salevehicle VALUES ('1A1B1C', 1953, 'Rolls-Royce', 'Silver Dawn', 25340, 'Grey', 'Bordeaux', 'Good', 'FORSALE', 35000.00, 50000.00, NULL, NULL, NULL);

        INSERT INTO salevehicle VALUES ('2A2B2C', 1960, 'Mercedes-Benz', '300 SL', 21311, 'Beige', 'Roadster', 'Excellent', 'FORSALE', 89950.00, 1156070.00, NULL, NULL, NULL);

        INSERT INTO salevehicle VALUES ('1FMJU2', 1960, 'Aston Martin', 'DB4', 29856, 'Grey', 'Zagato', 'Excellent', 'FORSALE', 9870000.00, 12980000.00, NULL, NULL, NULL);

        INSERT INTO salevehicle VALUES ('1GCPKP', 1990, 'Acura', 'NSX', 70690, 'Blue', '2 Door Coupe', 'Good', 'FORSALE', 48000.00, 69995.00, NULL, NULL, NULL);

        INSERT INTO salevehicle VALUES ('3D3E3F', 1963, 'Ferrari', '250 GTO', 18970, 'Red', '2 Door Coupe', 'Excellent', 'FORSALE', 40000000.00, 58000000.00, NULL, NULL, NULL);
    
    -- Sales with TRADEINs
    INSERT INTO salevehicle VALUES ('1FTRX1', 2019, 'Tesla', 'Model X', 20798, 'White', 'Utility', 'Good', 'TRADEIN', NULL, NULL, 60000.00, NULL, 1456);
    INSERT INTO Carseller (SELLER_ID, SELLER_CONTACT, SELLER_STREET, SELLER_CITY, SELLER_STATE, SELLER_ZIP_CODE, SELLER_PHONE)
    SELECT	CUSTOMER_ID, First_name || ' ' || Last_name, CUSTOMER_STREET, CUSTOMER_CITY, CUSTOMER_STATE, CUSTOMER_ZIP, CUSTOMER_PHONE
    FROM CUSTOMER
    WHERE CUSTOMER_ID = 1456;
    INSERT INTO purchase_invoice VALUES (011, 1000, 1456, '11-11-2020', 0.00, 0.00);
    INSERT INTO sales_invoice VALUES (011, 1071, NULL, 1456, '11-11-2020', 'cash', 199.99, 2500.00, 0.0725, NULL, '2A2B2C', '1FTRX1');
    UPDATE sales_invoice SET manager_id = 1000 WHERE sales_invoice_id = 011;
    UPDATE salevehicle SET Status = 'FORSALE', Customer_ID = NULL, Purchase_Price = 60000.00, List_Price = 65000.00 WHERE VEHICLE_VIN = '1FTRX1';
    UPDATE salevehicle SET Status = 'SOLD', Customer_ID = 1456 WHERE Vehicle_VIN = '2A2B2C';

    INSERT INTO salevehicle VALUES ('5N1AR1', 1968, 'Shelby', 'GT350', 24990, 'Green', 'Fastback', 'Excellent', 'TRADEIN', NULL, NULL, 105000.00, NULL, 1785);
    INSERT INTO Carseller (SELLER_ID, SELLER_CONTACT, SELLER_STREET, SELLER_CITY, SELLER_STATE, SELLER_ZIP_CODE, SELLER_PHONE)
    SELECT	CUSTOMER_ID, First_name || ' ' || Last_name, CUSTOMER_STREET, CUSTOMER_CITY, CUSTOMER_STATE, CUSTOMER_ZIP, CUSTOMER_PHONE
    FROM CUSTOMER
    WHERE CUSTOMER_ID = 1785;
    INSERT INTO purchase_invoice VALUES (012, 1000, 1785, '10-11-2020', 0.00, 0.00);
    INSERT INTO sales_invoice VALUES (014, 1079, NULL, 1785, '10-04-2020', 'bitcoin', 325.00, 20000.00, 0.0725, NULL, '1FMJU2', '5N1AR1');
    UPDATE sales_invoice SET manager_id = 1000 WHERE sales_invoice_id = 014;
    UPDATE salevehicle SET Status = 'FORSALE', Customer_ID = NULL, Purchase_Price = 105000.00, List_Price = 130000.00 WHERE VEHICLE_VIN = '5N1AR1';
    UPDATE salevehicle SET Status = 'SOLD', Customer_ID = 1785 WHERE Vehicle_VIN = '1FMJU2';

    INSERT INTO salevehicle VALUES ('2GKFLX', 2018, 'Lamborghini', 'Aventador', 26823, 'Black', 'S Roadster', 'Good', 'TRADEIN', NULL, NULL, 450000.00, NULL, 1875);
    INSERT INTO Carseller (SELLER_ID, SELLER_CONTACT, SELLER_STREET, SELLER_CITY, SELLER_STATE, SELLER_ZIP_CODE, SELLER_PHONE)
    SELECT	CUSTOMER_ID, First_name || ' ' || Last_name, CUSTOMER_STREET, CUSTOMER_CITY, CUSTOMER_STATE, CUSTOMER_ZIP, CUSTOMER_PHONE
    FROM CUSTOMER
    WHERE CUSTOMER_ID = 1875;
    INSERT INTO purchase_invoice VALUES (013, 1000, 1875, '10-05-2020', 0.00, 0.00);
    INSERT INTO sales_invoice VALUES (015, 1079, NULL, 1875, '10-05-2020', 'credit', NULL, 54000.00, 0.0725, 256.99, '3D3E3F', '2GKFLX');
    UPDATE sales_invoice SET manager_id = 1030 WHERE sales_invoice_id = 015;
    UPDATE salevehicle SET Status = 'FORSALE', Customer_ID = NULL, Purchase_Price = 450000.00, List_Price = 530000.00 WHERE VEHICLE_VIN = '2GKFLX';
    UPDATE salevehicle SET Status = 'SOLD', Customer_ID = 1875 WHERE Vehicle_VIN = '3D3E3F';

    -- Sales without TRADEINs
    INSERT INTO sales_invoice VALUES (012, 1071, NULL, 1234, '12-12-2020', 'credit', 250.00, NULL, 0.0725, NULL, '1A1B1C', NULL);
    UPDATE sales_invoice SET manager_id = 1030 WHERE sales_invoice_id = 012;
    UPDATE salevehicle SET Status = 'SOLD', Customer_ID = 1234 WHERE Vehicle_VIN = '1A1B1C';

    INSERT INTO sales_invoice VALUES (013, 1071, NULL, 8294, SYSDATE, 'cash', NULL, NULL, 0.0725, 301.33, '1GCPKP', NULL);
    UPDATE sales_invoice SET manager_id = 1000 WHERE sales_invoice_id = 013;
    UPDATE salevehicle SET Status = 'SOLD', Customer_ID = 8294 WHERE Vehicle_VIN = '1GCPKP';


-- Servicing Vehicles
    -- Servicing a Vehicle Sold By Us
        INSERT INTO servicevehicle (Vehicle_VIN, Vehicle_Year, Vehicle_Make, Vehicle_Model, Vehicle_Mileage, Customer_ID)
        SELECT Vehicle_VIN, Vehicle_Year, Vehicle_Make, Vehicle_Model, Vehicle_Mileage, (SELECT Customer_ID FROM salevehicle WHERE Vehicle_VIN = '1A1B1C')
        FROM salevehicle
        WHERE Vehicle_VIN = '1A1B1C';
        INSERT INTO service_invoice VALUES (001, 1045, 1026, 1234, '1A1B1C', '08-08-2020', 1, 0.0725);
            INSERT INTO service_list VALUES ('BATTERYREPLACE', 001);
            INSERT INTO part_list VALUES ('BATTERY', 001);
        
        INSERT INTO servicevehicle (Vehicle_VIN, Vehicle_Year, Vehicle_Make, Vehicle_Model, Vehicle_Mileage, Customer_ID)
        SELECT Vehicle_VIN, Vehicle_Year, Vehicle_Make, Vehicle_Model, Vehicle_Mileage, (SELECT Customer_ID FROM salevehicle WHERE Vehicle_VIN = '2A2B2C')
        FROM salevehicle
        WHERE Vehicle_VIN = '2A2B2C';
        INSERT INTO service_invoice VALUES (002, 1045, 1026, 1456, '2A2B2C', '02-02-2019', 2, 0.0725);
            INSERT INTO service_list VALUES ('BATTERYREPLACE', 002);

        INSERT INTO servicevehicle (Vehicle_VIN, Vehicle_Year, Vehicle_Make, Vehicle_Model, Vehicle_Mileage, Customer_ID)
        SELECT Vehicle_VIN, Vehicle_Year, Vehicle_Make, Vehicle_Model, Vehicle_Mileage, (SELECT Customer_ID FROM salevehicle WHERE Vehicle_VIN = '3D3E3F')
        FROM salevehicle
        WHERE Vehicle_VIN = '3D3E3F';
        INSERT INTO service_invoice VALUES (006, 1036, 1026, 1875, '3D3E3F', '01-01-2019', 8, 0.0725);
            INSERT INTO service_list VALUES ('OILCHG', 006);
            INSERT INTO part_list VALUES ('OIL10W30', 006);

    -- Servicing a Vehicle Not Sold By Us
        INSERT INTO servicevehicle VALUES ('3A3B3C', 2018, 'Ferrari', '430', 21311, 2928);
        INSERT INTO service_invoice VALUES (003, 1045, 1026, 2928, '3A3B3C', '03-03-2020', 3, 0.0725);
            INSERT INTO part_list VALUES ('OIL10W30', 003);

        INSERT INTO servicevehicle VALUES ('1D1E1F', 2011, 'Hyundai', 'Sonata', 115641, 8523);
        INSERT INTO service_invoice VALUES (004, 1036, 1026, 8523, '1D1E1F', '04-04-2020', 4, 0.0725);
            INSERT INTO service_list VALUES ('TUNEUPBASICS', 004);
            INSERT INTO part_list VALUES ('AIRFILTER', 004);

        INSERT INTO servicevehicle VALUES ('2D2E2F', 2020, 'Mercedes-Benz', 'A-Class', 8000, 4619);
        INSERT INTO service_invoice VALUES (005, 1036, 1026, 4619, '2D2E2F', '05-05-2020', 5, 0.0725);
            INSERT INTO service_list VALUES ('MULTIPOINTINTSP', 005);
            INSERT INTO part_list VALUES ('SPARKPLUG4', 005);

-- Create Views
CREATE OR REPLACE VIEW AllCustomer AS 
(
SELECT first_name "First Name", last_name "Last Name", customer_street "Street", customer_city "City", customer_state "State", customer_zip "Zip Code", customer_phone "Phone", customer_email "Email"
FROM customer
)
ORDER BY last_name;

CREATE OR REPLACE VIEW CustomerWithPref AS
(
SELECT c.first_name "First Name", c.last_name "Last Name", c.customer_phone "Phone", p.pref_make "Preferred Make", p.pref_model "Preferred Model", p.start_date "Start date", p.end_date "End date"
FROM customer c JOIN preference p
ON (c.customer_id = p.customer_id)
);

CREATE OR REPLACE VIEW AllCustomerWithPref AS
(
SELECT c.first_name "First Name", c.last_name "Last Name", c.customer_phone "Phone", p.pref_make "Preferred Make", NVL(p.pref_model,'No Preference') "Preferred Model", p.start_date "Start date", p.end_date "End date"
FROM customer c LEFT JOIN preference p
ON (c.customer_id = p.customer_id)
);

CREATE OR REPLACE VIEW EmpContactList AS
(
SELECT first_name "First Name", last_name "Last Name", employee_phone "Phone", employee_email "Email"
FROM employee
)
ORDER BY last_name;

CREATE OR REPLACE VIEW EmpReportingList AS
(
SELECT m.first_name || ' ' || m.last_name "Manager", m.employee_title "Title", w.first_name ||' '||w.last_name "Reportee", w.employee_title "Employee Title"
FROM employee m JOIN employee w
ON (w.manager_id = m.employee_id)
)
ORDER BY m.last_name;

CREATE OR REPLACE VIEW ServiceList AS
(
SELECT Service_code "Service code", service_desc "Description", service_cost "Cost", service_price "Price", service_months "Months", service_mileage "Mileage"
FROM carservice
)
ORDER BY Service_code;

CREATE OR REPLACE VIEW PartList AS
(
SELECT Part_code "Part code", part_desc "Description", part_cost "Cost", part_price "Price"
FROM part
)
ORDER BY part_code;

-- Create Views: Task 4

    CREATE OR REPLACE VIEW VehicleList AS
    (
    SELECT Vehicle_VIN "VIN", Vehicle_Year "Year", Vehicle_Make "Make", Vehicle_Model "Model", Exterior_Color AS "Exterior Color", Trim, Vehicle_Mileage "Mileage", Condition, Status, List_Price AS "List Base Price"
    FROM salevehicle
    )
    ORDER BY Vehicle_Make, Vehicle_Model;
    
    CREATE OR REPLACE VIEW VehiclesForSale AS
    (
    SELECT Vehicle_VIN "VIN", Vehicle_Year "Year", Vehicle_Make "Make", Vehicle_Model "Model", Exterior_Color AS "Exterior Color", Trim, Vehicle_Mileage "Mileage", Condition, Status, List_Price AS "List Base Price"
    FROM salevehicle
    WHERE Status = 'FORSALE'
    )
    ORDER BY Vehicle_Make, Vehicle_Model;
    
    CREATE OR REPLACE VIEW VehiclesSold AS
    (
    SELECT Vehicle_VIN "VIN", Vehicle_Year "Year", Vehicle_Make "Make", Vehicle_Model "Model", Vehicle_Mileage "Mileage", Condition, Status, List_Price AS "List Base Price"
    FROM salevehicle
    WHERE Status = 'SOLD'
    );
    
    CREATE OR REPLACE VIEW VehicleInventoryValue AS
    (
    SELECT SUM(List_Price) AS "Total Value of Vehicles For Sale"
    FROM salevehicle
    WHERE Status = 'FORSALE'
    );
    
    CREATE OR REPLACE VIEW InventoryValueByMake AS
    (
    SELECT Vehicle_Make "Make", SUM(List_Price) AS "Total Value of Vehicles For Sale"
    FROM salevehicle
    WHERE Status = 'FORSALE'
    GROUP BY Vehicle_Make
    )
    ORDER BY Vehicle_Make;
    
    CREATE OR REPLACE VIEW CarSellerList AS
    (
    SELECT Seller_Name AS "Company Name", Seller_Contact AS "Contact Name", Seller_Street || ' ' || Seller_City || ' ' || Seller_State || ' ' || Seller_Zip_Code "Address", Seller_Phone AS "Phone Number", Seller_Fax AS "Fax Number"
    FROM carseller
    )
    ORDER BY Seller_Name;

CREATE OR REPLACE VIEW ServiceInvoiceList
AS
(
SELECT se.service_invoice_id "Invoice Number", 
c.first_name || ' ' || c.last_name "Customer Name",
se.Vehicle_VIN "VIN", 
sv.Vehicle_Make "Make", 
sv.Vehicle_Model "Model", 
sv.Vehicle_Mileage "Mileage",
NVL(ROUND(SUM(cs.service_price), 2), 0) "Total Service Charge",
NVL(ROUND(SUM(p.part_price), 2), 0) "Total Parts Charge",
ROUND(NVL(ROUND(SUM(cs.service_price), 2), 0) + NVL(ROUND(SUM(p.part_price), 2), 0), 2) "Subtotal",
ROUND((NVL(SUM(cs.service_price), 0) + NVL(SUM(p.part_price), 0)) * se.Taxes, 2) "Taxes",
se.misc_charge "Misc",
ROUND(NVL(SUM(cs.service_price), 0) + NVL(SUM(p.part_price), 0) + (NVL(SUM(cs.service_price), 0) + NVL(SUM(p.part_price), 0)) * se.Taxes + se.misc_charge, 2) "Total Charges"

FROM service_invoice se
JOIN customer c
ON se.customer_id = c.customer_id
JOIN servicevehicle sv 
ON se.Vehicle_VIN = sv.Vehicle_VIN
LEFT JOIN service_list sl 
ON se.service_invoice_id = sl.service_invoice_id
LEFT JOIN carservice cs 
ON sl.service_code = cs.service_code
LEFT JOIN part_list pl 
ON se.service_invoice_id = pl.service_invoice_id
LEFT JOIN part p 
ON pl.part_code = p.part_code

GROUP BY se.service_invoice_id, c.first_name || ' ' || c.last_name, se.Vehicle_VIN, sv.Vehicle_Make, sv.Vehicle_Model, sv.Vehicle_Mileage, se.Taxes, se.misc_charge
)
ORDER BY se.service_invoice_id;
 
CREATE OR REPLACE VIEW VehiclePurchaseList 
AS
(
SELECT pu.PURCHASE_INVOICE_ID "Purchase Order Number", 
ca.SELLER_NAME "Company Name", 
ca.SELLER_CONTACT "Contact Name", 
sa.VEHICLE_VIN "VIN", 
sa.vehicle_make "Make", 
sa.vehicle_model "Model", 
sa.purchase_price "Sales Amount", 
pu.purchase_shipping "Shipping", 
ROUND(pu.purchase_taxes*(sa.purchase_price+pu.purchase_shipping),2) "Taxes", 
sa.purchase_price + NVL(pu.purchase_shipping,0) + ROUND(pu.purchase_taxes*(sa.purchase_price+pu.purchase_shipping),2) "Total Price",
em.first_name || ' ' || em.last_name "Manager Name"
FROM PURCHASE_INVOICE pu 
JOIN CARSELLER ca ON (pu.SELLER_ID = ca.seller_ID)
JOIN SALEVEHICLE sa ON (pu.SELLER_ID = sa.seller_ID)
JOIN EMPLOYEE em ON (pu.manager_id = em.employee_ID)
);

CREATE OR REPLACE VIEW VehicleSalesList AS
(
SELECT sa.sales_invoice_id "Invoice #", 
cu.first_name || ' ' || cu.last_name "Customer Name", 
emp.first_name || ' ' || emp.last_name "Salesperson", 
mn.first_name || ' ' || mn.last_name "Approved By", 
sa.sold_Vehicle_VIN "Sold Vehicle", 
ve.VEHICLE_MAKE "Make",ve.VEHICLE_model "Model", 
sa.tradein_Vehicle_VIN "Trade In", 
tr.vehicle_make "Trade In Make",
tr.vehicle_model "Trade In Model", 
ve.list_price "Selling Price", 
sa.sales_shipping "Shipping", 
sa.sales_discount "Discount", 
tr.TRADE_IN_ALLOWANCE "Trade In Allowance",
ve.list_price+NVL(sa.sales_shipping,0)-NVL(sa.sales_discount,0)-NVL(tr.TRADE_IN_ALLOWANCE,0) "Subtotal",
ROUND((ve.list_price+NVL(sa.sales_shipping,0)-NVL(sa.sales_discount,0)-NVL(tr.TRADE_IN_ALLOWANCE,0))*sa.sales_taxes, 2) "Tax",
sa.sales_misc "Miscellaneous Charge", 
ve.list_price+NVL(sa.sales_shipping,0)-NVL(sa.sales_discount,0)-NVL(tr.TRADE_IN_ALLOWANCE,0)+ROUND((ve.list_price+NVL(sa.sales_shipping,0)-NVL(sa.sales_discount,0)-NVL(tr.TRADE_IN_ALLOWANCE,0))*sa.sales_taxes,2)+NVL(sa.sales_misc,0) "Total Selling Price"
FROM sales_invoice sa JOIN employee emp
ON (sa.employee_id = emp.employee_id)
LEFT JOIN employee mn
ON (sa.manager_id = mn.employee_id)
JOIN salevehicle ve
ON (sa.Sold_Vehicle_VIN = ve.VEHICLE_VIN)
LEFT JOIN salevehicle tr
ON (sa.tradein_Vehicle_VIN = tr.VEHICLE_VIN)
JOIN customer cu
ON (sa.customer_id = cu.customer_id)
)
ORDER BY sa.sales_invoice_id;

--6-1
CREATE OR REPLACE VIEW CustomersWithPurchases
AS
(SELECT DISTINCT cu.first_name || ' ' || cu.last_name "Customer Name", cu.customer_phone "Customer Phone"
FROM customer cu
JOIN salevehicle sa
ON (cu.customer_id = sa.customer_id)
WHERE sa.status = 'SOLD');

--6-2
CREATE OR REPLACE VIEW CustomersPurchasedWithoutServiced
AS
( SELECT DISTINCT cu.first_name || ' ' || cu.last_name "Customer Name", cu.customer_phone "Customer Phone"
FROM salevehicle sa JOIN  customer cu ON (sa.customer_id = cu.customer_id)
WHERE sa.customer_id NOT IN 
(SELECT cu.customer_id
FROM customer cu
JOIN salevehicle sa
ON (cu.customer_id = sa.customer_id)
JOIN servicevehicle sv
ON (cu.customer_id = sv.customer_id)
WHERE sa.status= 'SOLD'));

--6-3
CREATE OR REPLACE VIEW PreferPorsche
AS
(SELECT DISTINCT cu.first_name || ' ' || cu.last_name "Customer Name", cu.customer_phone "Customer Phone"
FROM customer cu JOIN preference pr ON (cu.customer_id = pr.customer_id)
WHERE pr.PREF_MAKE = 'Porsche' AND pr.end_date >= SYSDATE);

--6-4
CREATE OR REPLACE VIEW BuyNotTrade
AS
(
SELECT DISTINCT  cu.first_name || ' ' || cu.last_name "Customer Name", customer_phone "Customer Phone"
FROM salevehicle sa JOIN customer cu ON (sa.customer_id = cu.customer_id)
WHERE sa.customer_id IN (
SELECT cu.customer_id
FROM customer cu JOIN sales_invoice sa ON (cu.customer_id = sa.customer_id)
WHERE sa.tradein_vehicle_vin IS NULL)
);

--6-5
CREATE OR REPLACE VIEW SoldInLast30Days
AS
(
SELECT iv.date_sold, sa.VEHICLE_VIN, sa.VEHICLE_MAKE, sa.VEHICLE_MODEL, sa.VEHICLE_YEAR, sa.List_price 
FROM salevehicle sa JOIN sales_invoice iv
ON (sa.vehicle_VIN = iv.sold_vehicle_VIN)
WHERE iv.date_sold >= (SYSDATE-30) AND iv.date_sold <= SYSDATE    
);

--6-6
CREATE OR REPLACE VIEW ProfitsFromService
AS
(SELECT sl.service_code "Service", COUNT(*) "Count", SUM(sv.service_price) - SUM(sv.service_cost) "Total Profit"
FROM carservice sv  JOIN  service_list sl 
ON (sv.service_code = sl.service_code)
GROUP BY sl.service_code, sv.service_price, sv.service_cost);

--6-7a
CREATE OR REPLACE VIEW HighestComissions
AS
(
SELECT first_name || ' ' || last_name "Employee Name", commission_pct "Commission"
FROM employee 
WHERE commission_pct = (SELECT MAX(commission_pct) FROM employee WHERE employee_id NOT IN (1030) )
);

CREATE OR REPLACE VIEW MostVehiclesSold
AS
( SELECT sa.employee_id "Employee ID", COUNT(*) "Cars Sold"
FROM employee em JOIN sales_invoice sa
ON (em.employee_id = sa.employee_id)
GROUP BY sa.employee_id
HAVING COUNT(*) =
(SELECT MAX(COUNT(*))
FROM employee em JOIN sales_invoice sa
ON (em.employee_id = sa.employee_id)
GROUP BY sa.employee_id) );

--6-8
CREATE OR REPLACE VIEW VehicleSales -- Our assumption was this implies revenue
AS
(
SELECT SUM(List_Price) "Vehicle Sales"
FROM salevehicle
WHERE Status = 'SOLD'
);

--EC1
CREATE OR REPLACE VIEW OilChangeMileage
AS
(SELECT DISTINCT cu.first_name || ' ' || cu.last_name "Customer Name", cu.customer_phone "Customer Phone",
sv.vehicle_VIN "VIN", sv.vehicle_make "Make"
FROM customer cu, servicevehicle sv
WHERE sv.vehicle_mileage > 6000);

--EC2
CREATE OR REPLACE VIEW OilChangeDate
AS
(SELECT DISTINCT cu.first_name || ' ' || cu.last_name "Customer Name", cu.customer_phone "Customer Phone",
sv.vehicle_VIN "VIN", sv.vehicle_make "Make"
FROM customer cu, servicevehicle sv, service_invoice se
JOIN service_list sl
ON (se.service_invoice_id = sl.service_invoice_id)
WHERE sl.service_code = 'OILCHG' AND se.date_serviced < (SYSDATE - 180));
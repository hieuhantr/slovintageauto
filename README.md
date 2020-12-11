# slovintageauto

List of attributes in the tables

Employee: Employee list
Employee_Id: the ID of an employee (start from 1000)
First_name: the employee’s first name
Last_name: the employee’s last name
Employee_street: street address of the employee
Employee_city: city of the employee
Employee_state: state of the employee
Employee_zip: state of the employee
Employee_phone: employee’s phone number
Employee_email: employee’s email address
Employee_title: employee’s phone number
Hire_date: employee’s hire date
Manager_id: the employee ID of the manager that employee reports to
Department_type: Department type of either “SA” (sales) “AC” (accounting), “SV” (service), or other
Commission_pct: Commission percentage for employees in sales department

Carservice: Car services 
Service_code: Code of service
Service_desc: Description of service
Service_cost: Cost of service
Service_price: Price of service
Service_months: Months requirement for service
Service_mileage: Mileage requirement for service

Part: Car part for services
Part_code: Code of part
Part_desc: Description of part
Part_cost: Cost of part
Part_price: Price of part


Customer: List of customers
Customer_id: ID of customer
First_name: First name of customer
Last_name: Last name of customer
Customer_street: Street address of customer
Customer_city: City of customer
Customer_state: State of customer
Customer_zip: Zip code of customer
Customer_phone: Phone number of customer
Customer_email: Email of customer


Preference
Pref_id: ID of the preference
Customer_id: ID of customer with that preference
Pref_make: Preferred make
Pref_model: Preferred model
Pref_year: Preferred year of car
Pref_desc: Other description of preference
Start_date: Effective start date of preference
End_date: End date of preference

CarSeller
Seller_ID: ID of the Car Seller within the system
Seller_Name: Name of the Car Seller Company
Seller_Contact: The name of the point of Car Seller contact person
Seller_Street: Street address of the Car Seller
Seller_City: City of Car Seller
Seller_State: State abbreviation of Car Seller
Seller_Zip_Code: 5 digit zip code of Car Seller
Seller_Phone: 10 digit phone number of Car Seller
Seller_Fax: 10 digit fax number of Car Seller

ServiceVehicle
Vehicle_VIN: 17 character VIN for vehicle (mixture of letters and numbers)
Vehicle_Year: Year of the vehicle model
Vehicle_Make: Make of the vehicle
Vehicle_Model: Model of the vehicle
Vehicle_Mileage: Amount of miles on the vehicle
Customer_ID: identification number of customer

SaleVehicle
Vehicle_VIN: 17 character VIN for vehicle (mixture of letters and numbers)
Vehicle_Year: Year of the vehicle model
Vehicle_Make: Make of the vehicle
Vehicle_Model: Model of the vehicle
Vehicle_Mileage: Amount of miles on the vehicle
Exterior_Color: Exterior color of the vehicle
Trim: Trim of the vehicle
Condition: The condition the vehicle is in
Status: Selling status of the vehicle (i.e. Sold, Not Sold)
Purchase_Price: The amount the new sale vehicle was purchased for from an auto vendor or the “trade-in allowance” for vehicles acquired via trade-ins
List_Price: The price a new sale vehicle is listed for
Trade_In_Allowance: amount of money received from trade-in car
Seller_ID: identification number of Car Seller selling the vehicle
Customer_ID: identification number of customer

Service_ invoice_id : invoice ID
ServiceInvoiceList: Service Invoice View
Date_serviced: date serviced
Service_price: service charges
Part_price: part charges
Taxes: taxes
Misc_charge: miscellaneous charges

Purchase_invoice_id: purchase invoice ID
VehiclePurchaseList: Purchase invoice View
Date_purchased: date purchased
Purchase_shipping: shipping cost for PO
Purchase_taxes: taxes cost for PO
Total_purchase: total price of purchase

Sales_invoice_id: Sales invoice ID
VehicleSalesList: Sales invoice View
Date_sold: date car/part was sold
Terms: terms of the sale
Sales_shipping: shipping cost for sales invoice
Sales_discount: trade-in allowance for trade-in vehicle
Sales_taxes: taxes cost for sales invoice
Sales_misc: misc charges on sales invoice
sold_vehicle_VIN: vehicle identification number for vehicle of sold status
TradeIn_vehicle_VIN: vehicle identification number for vehicle of trade-in status

Service_list: identifier for list of services
Service_code: identifier for service operation
Service_invoice_id: service invoice ID

Part_list: identifier for list of parts
Part_code: identifier for part
Service_invoice_id: service invoice ID

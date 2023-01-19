DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS account_type CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS employee_rank CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS payees CASCADE;
DROP TABLE IF EXISTS transfer CASCADE;
DROP TABLE IF EXISTS payments CASCADE;

CREATE TABLE "customer" (
  "Customer_ID" Serial,
  "Customer_Username" Varchar(255),
  "Customer_Address" Varchar(255),
  "Customer_Firstname" Varchar(255),
  "Customer_Lastname" Varchar(255),
  "Customer_Contacts" Varchar(255),
  "Customer_Password" Varchar(255),
  "Date_Joined" timestamp without time zone,
  PRIMARY KEY ("Customer_ID")
);

CREATE TABLE "account_type" (
  "Account_Type_ID" Serial,
  "Account_Type" Varchar(255) ,
  PRIMARY KEY ("Account_Type_ID")
);

CREATE TABLE "accounts" (
  "Account_ID" Serial,
  "Customer_ID" Integer,
  "Account_Type_ID" Integer,
  "Account_Balance" Money,
  "Date_Created" timestamp without time zone,
  "Account_Credit" Money,
  PRIMARY KEY ("Account_ID"),
  CONSTRAINT "FK_accounts.Customer_ID"
    FOREIGN KEY ("Customer_ID")
      REFERENCES "customer"("Customer_ID"),
  CONSTRAINT "FK_accounts.Account_Type_ID"
    FOREIGN KEY ("Account_Type_ID")
      REFERENCES "account_type"("Account_Type_ID")
);

CREATE TABLE "employee_rank" (
  "Employee_Rank_ID" Serial,
  "Rank_Name" Varchar(50),
  "Rank_Description " Varchar(255),
  "Rank_Privileges" Varchar(150),
  PRIMARY KEY ("Employee_Rank_ID")
);

CREATE TABLE "employee" (
  "Employee_ID" Serial,
  "Employee_Rank_ID" Integer,
  "Employee_Address" Varchar(255) Not Null,
  "Employee_Firstname" Varchar(255),
  "Employee_Lastname" Varchar(255),
  "Employee_Password" Varchar(255),
  "Employee_Username" Varchar(255),
  "Date_Joined" timestamp without time zone,
  PRIMARY KEY ("Employee_ID"),
  CONSTRAINT "FK_employee.Employee_Rank_ID"
    FOREIGN KEY ("Employee_Rank_ID")
      REFERENCES "employee_rank"("Employee_Rank_ID")
);

CREATE TABLE "loans" (
  "Loan_ID" Serial,
  "Account_ID" Integer,
  "Employee_ID" Integer,
  "Loan_Status" Varchar(200),
  "Loan_Amount" Money,
  "Date_Of_Request" timestamp without time zone,
  PRIMARY KEY ("Loan_ID"),
  CONSTRAINT "FK_loans.Account_ID"
    FOREIGN KEY ("Account_ID")
      REFERENCES "accounts"("Account_ID"),
  CONSTRAINT "FK_employee.Employee_ID"
    FOREIGN KEY ("Employee_ID")
      REFERENCES "employee"("Employee_ID")
);




CREATE TABLE "payees" (
  "Payee_ID" Serial,
  "Customer_ID" Integer,
  "Payee_Account_ID" Integer,
  "Payee_Sort_Code" Integer,
  "Payee_Description" Varchar(255),
  PRIMARY KEY ("Payee_ID"),
  CONSTRAINT "FK_payees.Customer_ID"
    FOREIGN KEY ("Customer_ID")
      REFERENCES "customer"("Customer_ID")
);

CREATE TABLE "transfer" (
  "Transaction_ID" Serial,
  "Payee_ID" Integer,
  "Account_ID" Integer,
  "Amount_Sent" Money,
  "Date_Sent" timestamp without time zone,
  PRIMARY KEY ("Transaction_ID"),
  CONSTRAINT "FK_transfer.Payee_ID"
    FOREIGN KEY ("Payee_ID")
      REFERENCES "payees"("Payee_ID"),
  CONSTRAINT "FK_transfer.Account_ID"
    FOREIGN KEY ("Account_ID")
      REFERENCES "accounts"("Account_ID")
);

CREATE TABLE "payments" (
  "Payment_ID" Serial,
  "Loan_ID" Integer,
  "Amount_Paid" Money,
  "Date_Of_Payment" timestamp without time zone,
  PRIMARY KEY ("Payment_ID"),
  CONSTRAINT "FK_payments.Loan_ID"
    FOREIGN KEY ("Loan_ID")
      REFERENCES "loans"("Loan_ID")
);

create role manager;
grant connect on database imcw to manager;
grant pg_read_all_data to manager;
grant pg_write_all_data to manager;
create role employee;
create role customer;
grant select on 
-- MAYBE USE SCHEMAs INSTEAD OF GROUP ROLES
-- AS THESE CAN BE USED MUCH QUICKER

create or replace procedure customer_role_creation(username varchar(255))
language plpgsql
as
$$
declare
begin
    create role username with login password '1234';
    grant role customer to username;
end;
$$;

create or replace procedure customer_creation(entry_firstname varchar(255), entry_lastname varchar(255), entry_address varchar(255), 
entry_contacts varchar(255))
language plpgsql
as
$$
declare 
date_of_creation timestamp without time zone;
username Varchar(255);
current_id Integer;
begin
    date_of_creation := (select localtimestamp(0));
    if (select count(*) from customer) = 0 THEN
          current_id := 1;
    else
       current_id := (select count(*) from customer) + 1;
    end if;
    username := (select(CONCAT((select left(entry_firstname, 1)), entry_lastname, current_id)));
    insert into customer("Customer_Firstname", "Customer_Lastname", "Customer_Address", "Customer_Contacts", "Customer_Username", "Date_Joined") 
    values(entry_firstname, entry_lastname, entry_address, entry_contacts, username, date_of_creation);
    call customer_role_creation(username);
end;
$$;


create or replace procedure account_application(Customer_ID Integer, requested_account_type varchar(255), initial_amount_entered Money)
language plpgsql
as
$$
declare
begin

end;
$$;



create or replace procedure customer_balance_transfer(value1 Integer, value2 Integer, value3 Money)
language plpgsql
as
$$
begin
    update accounts
    set Account_Balance = Account_Balance - Amount_Sent
    where Account_ID = value2;

    update accounts
    set Account_Balance = Account_Balance + Amount_Sent
    where Account_ID = value1;

    commit;
end;
$$;

DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS employee_rank CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS payees CASCADE;
DROP TABLE IF EXISTS transfer CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
drop table if exists cards cascade;
drop table if exists alter_request cascade;
drop table if exists debit_account cascade;
drop table if exists credit_account cascade;

create extension if not exists pgcrypto;

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

CREATE TABLE "credit_account" (
  "Account_ID" Serial,
  "Credit_Limit" Money,
  "Credit_Outstanding" Money, check ("Credit_Outstanding" <= "Credit_Limit"),
  "Date_Created" timestamp without time zone,
  "Payment_Interval_In_Days" Integer,
  PRIMARY KEY ("Account_ID")
);

CREATE TABLE "debit_account" (
  "Account_ID" Serial,
  "Sort_Code" varchar(8),
  "Balance" Money check ("Balance" >= '£0.00' - "Overdraft"),
  "Overdraft" Money,
  "Date_Created" timestamp without time zone,
  PRIMARY KEY ("Account_ID")
);

CREATE TABLE "employee_rank" (
  "Employee_Rank_ID" Serial,
  "Rank_Name" Varchar(50),
  "Rank_Description" Varchar(255),
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

CREATE TABLE "cards" (
  "Card_ID" Serial,
  "Customer_ID" Integer,
  "Debit_ID" Integer,
  "Credit_ID" Integer,
  "Card_Type" Varchar(10),
  PRIMARY KEY ("Card_ID"),
  CONSTRAINT "FK_Cards.Customer_ID"
    FOREIGN KEY ("Customer_ID")
      REFERENCES "customer"("Customer_ID"),
  CONSTRAINT "FK_Cards.Debit_ID"
    FOREIGN KEY ("Debit_ID")
      REFERENCES "debit_account"("Account_ID"),
  CONSTRAINT "FK_Cards.Credit_ID"
    FOREIGN KEY ("Credit_ID")
      REFERENCES "credit_account"("Account_ID")
);

CREATE TABLE "loans" (
  "Loan_ID" Serial,
  "Card_ID" Integer,
  "Employee_ID" Integer,
  "Loan_Status" Varchar(200),
  "Loan_Amount" Money,
  "Date_Of_Request" timestamp without time zone,
  PRIMARY KEY ("Loan_ID"),
  CONSTRAINT "FK_loans.Card_ID"
    FOREIGN KEY ("Card_ID")
      REFERENCES "cards"("Card_ID"),
  CONSTRAINT "FK_employee.Employee_ID"
    FOREIGN KEY ("Employee_ID")
      REFERENCES "employee"("Employee_ID")
);

CREATE TABLE "payees" (
  "Payee_ID" Serial,
  "Customer_ID" Integer,
  "Payee_Account_ID" Integer,
  "Payee_Sort_Code" varchar(8),
  "Payee_Description" Varchar(255),
  PRIMARY KEY ("Payee_ID"),
  CONSTRAINT "FK_payees.Customer_ID"
    FOREIGN KEY ("Customer_ID")
      REFERENCES "customer"("Customer_ID")
);

CREATE TABLE "transfer" (
  "Transaction_ID" Serial,
  "Payee_ID" Integer,
  "Card_ID" Integer,
  "Amount_Sent" Money,
  "Date_Sent" timestamp without time zone,
  PRIMARY KEY ("Transaction_ID"),
  CONSTRAINT "FK_transfer.Payee_ID"
    FOREIGN KEY ("Payee_ID")
      REFERENCES "payees"("Payee_ID"),
  CONSTRAINT "FK_transfer.Card_ID"
    FOREIGN KEY ("Card_ID")
      REFERENCES "cards"("Card_ID")
);

CREATE TABLE "payments" (
  "Payment_ID" Serial,
  "Loan_ID" Integer,
  "Amount_Paid" Money,
  "Amount_Left_To_Pay" Money,
  "Date_Of_Payment" timestamp without time zone,
  PRIMARY KEY ("Payment_ID"),
  CONSTRAINT "FK_payments.Loan_ID"
    FOREIGN KEY ("Loan_ID")
      REFERENCES "loans"("Loan_ID")
);

CREATE TABLE "alter_request" (
  "Request_ID" Serial,
  "Card_ID" Integer,
  "Account_Type" Varchar(8),
  "Request_Type" Varchar(20),
  "Altered_By" Money,
  "Request_Status" Varchar(20),
  "Approved_by_employee" Integer,
  "Date_Of_Request" Timestamp without time zone,
  PRIMARY KEY ("Request_ID"),
  CONSTRAINT "FK_alter_request.Card_ID"
    FOREIGN KEY ("Card_ID")
      REFERENCES "cards"("Card_ID"),
  CONSTRAINT "FK_alter_request.Approved_by_employee"
    FOREIGN KEY ("Approved_by_employee")
      REFERENCES "employee"("Employee_ID")
);

insert into employee_rank("Rank_Name", "Rank_Description", "Rank_Privileges") values(
  'Employee', 'Basic Employee', 'Able to: read all tables'),
  ('Manager', 'Higher Up Employee', 'Able to: read, write all tables');

---------------------------------------
---------------------------------------


create role manager;
grant connect on database imcw to manager;
create role employee;
create role customer;
grant select on table customer to customer;
grant select on table debit_account to customer;
grant select on table credit_account to customer;
grant select on table loans to customer;
grant select on table payees to customer;
grant select on table cards to customer;
grant select on table transfer to customer;
grant select on table alter_request to customer;
grant select on table payments to customer;

grant select on table customer to employee;
grant select on table debit_account to employee;
grant select on table credit_account to employee;
grant select on table loans to employee;
grant select on table payees to employee;
grant select on table cards to employee;
grant select on table transfer to employee;
grant select on table alter_request to employee;
grant select on table payments to employee;
grant select on table employee to employee;

grant all on table customer to manager;
grant all on table debit_account to manager;
grant all on table credit_account to manager;
grant all on table loans to manager;
grant all on table payees to manager;
grant all on table cards to manager;
grant all on table transfer to manager;
grant all on table alter_request to manager;
grant all on table payments to manager;
grant all on table employee to manager;
grant all on table employee_rank to manager;


alter table customer enable row level security;
alter table cards enable row level security;
alter table credit_account enable row level security;
alter table debit_account enable row level security;
alter table alter_request enable row level security;
alter table loans enable row level security;
alter table transfer enable row level security;
alter table payees enable row level security;
alter table payments enable row level security;

-- TO DO --
-- . Create Views and Policies for Manager and Employee
-- . 

CREATE POLICY secure ON customer TO customer USING("Customer_Username" = (select current_user));
CREATE POLICY secure ON cards TO customer USING((select "Customer_ID" from customer where ("Customer_Username" = (select current_user))) = "Customer_ID");
CREATE POLICY secure ON credit_account TO customer USING("Account_ID" = (select "Credit_ID" from cards where "Customer_ID" = (select "Customer_ID" from customer where ("Customer_Username" = (select current_user))) and "Card_Type" = 'Credit'));
CREATE POLICY secure ON debit_account TO customer USING("Account_ID" = (select "Debit_ID" from cards where "Customer_ID" = (select "Customer_ID" from customer where "Customer_Username" = (select current_user)) and "Card_Type" = 'Debit'));
CREATE POLICY secure on alter_request TO customer USING("Card_ID" = (select "Card_ID" from cards where "Customer_ID" = (select "Customer_ID" from customer where "Customer_Username" = (select current_user))));
CREATE POLICY secure on loans TO customer USING("Card_ID" = (select "Card_ID" from cards where "Customer_ID" = (select "Customer_ID" from customer where ("Customer_Username" = (select current_user)))));
CREATE POLICY secure on transfer TO customer USING("Card_ID" = (select "Card_ID" from cards where "Customer_ID" = (select "Customer_ID" from customer where ("Customer_Username" = (select current_user)))));
CREATE POLICY secure on payees TO customer USING("Customer_ID" = (select "Customer_ID" from customer where ("Customer_Username" = (select current_user))));
CREATE POLICY secure ON payments TO customer USING("Loan_ID" = (select "Loan_ID" from loans where "Card_ID" = (select "Card_ID" from cards where "Customer_ID" = (select "Customer_ID" from customer where ("Customer_Username" = (select current_user))))));

CREATE POLICY secure_employee ON customer TO employee USING("Customer_Username" = "Customer_Username");
CREATE POLICY secure_employee ON cards TO employee USING("Card_ID" = "Card_ID");
CREATE POLICY secure_employee ON credit_account TO employee USING("Account_ID" = "Account_ID");
CREATE POLICY secure_employee ON debit_account TO employee USING("Account_ID" = "Account_ID");
CREATE POLICY secure_employee ON alter_request TO employee USING("Request_ID" = "Request_ID");
CREATE POLICY secure_employee ON loans TO employee USING("Loan_ID" = "Loan_ID");
CREATE POLICY secure_employee ON transfer TO employee USING("Transaction_ID" = "Transaction_ID");
CREATE POLICY secure_employee ON payees TO employee USING("Payee_ID" = "Payee_ID");
CREATE POLICY secure_employee ON payments TO employee USING("Payment_ID" = "Payment_ID");
CREATE POLICY secure_employee ON employee TO employee USING("Employee_Username" = (select current_user));

CREATE POLICY secure_manager ON customer TO manager USING("Customer_Username" = "Customer_Username");
CREATE POLICY secure_manager ON cards TO manager USING("Card_ID" = "Card_ID");
CREATE POLICY secure_manager ON credit_account TO manager USING("Account_ID" = "Account_ID");
CREATE POLICY secure_manager ON debit_account TO manager USING("Account_ID" = "Account_ID");
CREATE POLICY secure_manager ON alter_request TO manager USING("Request_ID" = "Request_ID");
CREATE POLICY secure_manager ON loans TO manager USING("Loan_ID" = "Loan_ID");
CREATE POLICY secure_manager ON transfer TO manager USING("Transaction_ID" = "Transaction_ID");
CREATE POLICY secure_manager ON payees TO manager USING("Payee_ID" = "Payee_ID");
CREATE POLICY secure_manager ON payments TO manager USING("Payment_ID" = "Payment_ID");
CREATE POLICY secure_manager ON employee TO manager USING("Employee_ID" = "Employee_ID");
CREATE POLICY secure_manager ON employee_rank TO manager USING("Employee_Rank_ID" = "Employee_Rank_ID");

------------------------------
------------------------------

create or replace procedure customer_role_creation(username varchar(255), password_ varchar(255))
language plpgsql 
SECURITY definer
as
$$
declare
begin
    execute 'create role "'||username||'" with login password '''||password_||''';
    grant customer to "'||username||'"';
end;
$$;

create or replace procedure account_creation(username varchar(255), requested_account_type varchar(255))
language plpgsql
SECURITY definer
as
$$
declare
    date_of_creation timestamp without time zone;
    current_id Integer;
    Sort_Code varchar(8);
    cred_limit Money;
    deb_id Integer;
    cred_id Integer;
begin
    date_of_creation := (select localtimestamp(0));
    current_id := (select "Customer_ID" from customer where username = "Customer_Username");
    Sort_Code := '20-07-80';
    cred_limit := '£500.00';
    if (requested_account_type = 'Debit') THEN
        insert into debit_account("Date_Created", "Balance", "Sort_Code", "Overdraft") values(date_of_creation, '£0.00', Sort_Code, '£100.00');
        deb_id := (select count(*) from debit_account);
        insert into cards("Customer_ID", "Debit_ID","Card_Type") values(current_id, deb_id, 'Debit');
    elsif (requested_account_type = 'Credit') THEN
        insert into credit_account("Date_Created", "Credit_Limit", "Credit_Outstanding", "Payment_Interval_In_Days") values(date_of_creation, cred_limit , '£0.00' ,'30');
        cred_id := (select count(*) from credit_account);
        insert into cards("Customer_ID", "Credit_ID", "Card_Type") values(current_id, cred_id, 'Credit');
    end if;
end;
$$;

create or replace procedure customer_creation(entry_firstname varchar(255), entry_lastname varchar(255), entry_address varchar(255), 
entry_contacts varchar(255), entry_password varchar(255))
language plpgsql
SECURITY definer
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
    insert into customer("Customer_Firstname", "Customer_Lastname", "Customer_Address", "Customer_Contacts", "Customer_Username", "Date_Joined", "Customer_Password") 
    values(entry_firstname, entry_lastname, entry_address, entry_contacts, username, date_of_creation, crypt(entry_password, gen_salt('bf')));
    call customer_role_creation(username, entry_password);
    call account_creation(username, 'Debit');
    call account_creation(username, 'Credit');
end;
$$;

create or replace procedure pay_off_loan(Loan_ID Integer, Money_Paid Money)
language plpgsql
SECURITY definer
as
$$
declare
date_of_creation timestamp without time zone;
loan_amount Money;
acc_id Int;
acc_bal Money;
to_pay Money;
begin
      date_of_creation := (select localtimestamp(0));
      loan_amount := (select "Loan_Amount" from loans where "Loan_ID" = Loan_ID);
      acc_id := (select "Account_ID" from debit_account where "Account_ID" = (select "Debit_ID" from cards where "Card_ID" = (select "Card_ID" from loans where "Loan_ID" = Loan_ID)));
      acc_bal := (select "Balance" from debit_account where "Account_ID" = acc_id);
      if Loan_ID not in (select "Loan_ID" from payments) then
          if Money_Paid > acc_bal THEN
              raise exception 'Amount attempted to input is greater than account balance';
          elsif Money_Paid > loan_amount THEN
              insert into payments("Loan_ID", "Amount_Paid", "Date_Of_Payment", "Amount_Left_To_Pay") values (Loan_ID, loan_amount, date_of_creation, '£0');
              update debit_account set "Balance" = "Balance" - loan_amount where "Account_ID" = acc_id;
          else
              to_pay := loan_amount - Money_Paid;
              insert into payments("Loan_ID", "Amount_Paid", "Date_Of_Payment", "Amount_Left_To_Pay") values (Loan_ID, Money_Paid, date_of_creation, to_pay);
              update debit_account set "Balance" = "Balance" - Money_Paid where "Account_ID" = acc_id;
          end if;
      elsif Loan_ID in (select "Loan_ID" from payments) then
          to_pay := (select "Amount_Left_To_Pay" from payments where "Loan_ID" = Loan_ID and "Payment_ID" = (select max("Payment_ID") from payments where "Loan_ID" = Loan_ID));
          if Money_Paid > to_pay then
              insert into payments("Loan_ID", "Amount_Paid", "Date_Of_Payment", "Amount_Left_To_Pay") values (Loan_ID, loan_amount, date_of_creation, '£0');
              update debit_account set "Balance" = "Balance" - to_pay where "Account_ID" = acc_id;
          elsif to_pay > Money_Paid then
              to_pay := to_pay - Money_Paid;
              insert into payments("Loan_ID", "Amount_Paid", "Date_Of_Payment", "Amount_Left_To_Pay") values (Loan_ID, Money_Paid, date_of_creation, to_pay);
              update debit_account set "Balance" = "Balance" - Money_Paid where "Account_ID" = acc_id;
          end if;
      end if;
end;
$$;

create or replace procedure apply_loans(Account_ID Integer, Loan_Amount Money)
language plpgsql
SECURITY definer
as
$$
declare
date_of_creation timestamp without time zone;
card_id Integer;
begin
      date_of_creation := (select localtimestamp(0));
      card_id := (select "Card_ID" from cards where "Debit_ID" = Account_ID);
      if Account_ID not in (select "Account_ID" from debit_account) THEN
          raise exception 'Account with ID % is not in database!', Account_ID;
      else
          insert into loans("Card_ID", "Loan_Amount", "Date_Of_Request", "Loan_Status") values(card_id, Loan_Amount, date_of_creation, 'Pending');
     end if;
end;
$$;

create or replace procedure requests_for_account(Card_ID Integer, Request Varchar(20), Alter_Value Money)
language plpgsql
SECURITY definer
as
$$
declare
card_type Varchar(8);
date_of_creation timestamp without time zone;
begin
    date_of_creation := (select localtimestamp(0));
    card_type := (select "Card_Type" from cards where "Card_ID" = Card_ID);
    if card_type = 'Credit' THEN
      if Request = 'Increase' then
        insert into alter_request("Card_ID", "Account_Type", "Request_Type", "Altered_By", "Date_Of_Request", "Request_Status")
        values(Card_ID, card_type, 'Credit Increase', Alter_Value, date_of_creation, 'Pending');
      elsif Request = 'Decrease' then
        insert into alter_request("Card_ID", "Account_Type", "Request_Type", "Altered_By", "Date_Of_Request", "Request_Status")
        values(Card_ID, card_type, 'Credit Decrease', Alter_Value, date_of_creation, 'Pending');
      end if;
    elsif card_type = 'Debit' then
      if Request = 'Increase' then
        insert into alter_request("Card_ID", "Account_Type", "Request_Type", "Altered_By", "Date_Of_Request", "Request_Status")
        values(Card_ID, card_type, 'Overdraft Increase', Alter_Value, date_of_creation, 'Pending');
      elsif Request = 'Decrease' then
        insert into alter_request("Card_ID", "Account_Type", "Request_Type", "Altered_By", "Date_Of_Request", "Request_Status")
        values(Card_ID, card_type, 'Overdraft Decrease', Alter_Value, date_of_creation, 'Pending');
      end if;
    end if;
end;
$$;

create or replace procedure payee_creation(customer_id Integer, payee_account_id Integer, payee_sort_code Varchar(8))
language plpgsql
SECURITY definer
as
$$
declare
begin
    if payee_account_id not in (select "Payee_Account_ID" from payees where "Customer_ID" = customer_id) then
        insert into payees("Customer_ID", "Payee_Account_ID", "Payee_Sort_Code") values(customer_id, payee_account_id, payee_sort_code);
    end if;
end;
$$;

create or replace procedure customer_balance_transfer(payee_card_id Integer, payer_card_id Integer, value3 Money)
language plpgsql
SECURITY definer
as
$$
declare 
date_of_creation timestamp without time zone;
current_id Integer;
payee_id Integer;
payer_card_type Varchar(10);
payee_card_type Varchar(10);
payee_sort_code varchar(8);
payer_account_id Integer;
payee_account_id Integer;
begin
    date_of_creation := (select localtimestamp(0));
    current_id := (select "Customer_ID" from customer where "Customer_Username" = (select current_user));
    payer_card_type := (select "Card_Type" from cards where "Card_ID" = payer_card_id);
    payee_card_type := (select "Card_Type" from cards where "Card_ID" = payee_card_id);
        if (payer_card_type = 'Debit' and payee_card_type = 'Debit') THEN
            payee_account_id := (select "Debit_ID" from cards where "Card_ID" = payee_card_id);
            payer_account_id := (select "Debit_ID" from cards where "Card_ID" = payer_card_id);
            update debit_account
            set "Balance" = "Balance" - value3
            where ("Account_ID" = payee_account_id);
            update debit_account
            set "Balance" = "Balance" + value3
            where ("Account_ID" = payer_account_id);
            payee_sort_code := (select "Sort_Code" from debit_account where "Account_ID" = (select "Debit_ID" from cards where "Card_ID" = payee_card_id and "Card_Type" = 'Debit'));
            call payee_creation(current_id, payee_card_id, payee_sort_code);
        elsif (payer_card_type = 'Credit' and payee_card_type = 'Debit') THEN
            payee_account_id := (select "Debit_ID" from cards where "Card_ID" = payee_card_id);
            payer_account_id := (select "Credit_ID" from cards where "Card_ID" = payer_card_id);
            update credit_account 
            set "Credit_Outstanding" = "Credit_Outstanding" + value3 
            where ("Account_ID" = payer_account_id);
            update debit_account
            set "Balance" = "Balance" + value3
            where ("Account_ID" = payee_account_id);
            payee_sort_code := 'N/A';
            call payee_creation(current_id, payee_card_id, payee_sort_code);
        else
            raise exception 'Transfer to credit is not allowed!';
        end if;
    payee_id := (select "Payee_ID" from payees where ("Payee_Account_ID" = payee_card_id));
    insert into transfer("Payee_ID", "Card_ID", "Amount_Sent", "Date_Sent") values(payee_id, payer_card_id, value3, date_of_creation);
end;
$$;
--------------------------
--------------------------
create or replace procedure employee_role_creation(username varchar(255), entry_rank Integer, password_ varchar(255))
language plpgsql
SECURITY definer
as
$$
declare
begin
    IF (entry_rank = '1') THEN
        execute 'create role "'||username||'"with login password "'||password_||'";
        grant employee to "'||username||'"';
    elsif (entry_rank = '2') THEN
        execute 'create role "'||username||'"with login password "'||password_||'";
        grant manager to "'||username||'"';
    end if;
end;
$$;

create or replace procedure employee_creation(entry_firstname varchar(255), entry_lastname varchar(255), entry_address varchar(255), 
entry_rank Integer, entry_password varchar(255))
language plpgsql
SECURITY definer
as
$$
declare 
date_of_creation timestamp without time zone;
username Varchar(255);
current_id Integer;
begin
    date_of_creation := (select localtimestamp(0));
    if (select count(*) from employee) = 0 THEN
          current_id := 1;
    else
       current_id := (select count(*) from employee) + 1;
    end if;
    username := (select(CONCAT((select left(entry_firstname, 1)), entry_lastname, current_id, '@bank.com')));
    insert into employee("Employee_Firstname", "Employee_Lastname", "Employee_Address", "Employee_Username", "Date_Joined", "Employee_Rank_ID", "Employee_Password") 
    values(entry_firstname, entry_lastname, entry_address, username, date_of_creation, entry_rank, crypt(entry_password, gen_salt('bf')));
    call employee_role_creation(username, entry_rank, entry_password);
end;
$$;

create or replace procedure loan_acceptance(loan_id Integer, loan_status varchar(25))
language plpgsql
SECURITY definer
as
$$
declare
loan_amount Money;
old_status varchar(25);
account_id Int;
begin
    loan_amount := (select "Loan_Amount" from loans where "Loan_ID" = loan_id);
    old_status := (select "Loan_Status" from loans where "Loan_ID" = loan_id);
    if old_status = 'Pending' THEN
        update loans set "Loan_Status" = loan_status where "Loan_ID" = loan_id;
        if loan_status = 'Accepted' THEN
            update debit_account set "Balance" = "Balance" + loan_amount 
            where "Account_ID" = (select "Account_ID" from loans where "Loan_ID" = loan_id);
        end if;
    end if;
end;
$$;

create or replace procedure request_acceptance(Request_ID Integer, New_Request_Status Varchar(20))
language plpgsql
SECURITY definer
as
$$
declare
request Varchar(20);
account_id Integer;
alter_amount Money;
begin
    alter_amount := (select "Altered_By" from alter_request where "Request_ID" = Request_ID);
    request := (select "Request_Type" from alter_request where "Request_ID" = Request_ID);
    if New_Request_Status = 'Accepted' THEN
      update alter_request set "Request_Status" = 'Accepted' where "Request_ID" = Request_ID;
      if request = 'Credit Increase' THEN
          account_id := (select "Credit_ID" from cards where "Card_ID" = (select "Card_ID" from alter_request where "Request_ID" = Request_ID));
          update credit_account
          set "Credit_Limit" = "Credit_Limit" + alter_amount
          where "Account_ID" = account_id;
      elsif request = 'Credit Decrease' THEN
          account_id := (select "Credit_ID" from cards where "Card_ID" = (select "Card_ID" from alter_request where "Request_ID" = Request_ID));
          update credit_account
          set "Credit_Limit" = "Credit_Limit" - alter_amount
          where "Account_ID" = account_id;
      elsif request = 'Overdraft Increase' THEN
          account_id := (select "Debit_ID" from cards where "Card_ID" = (select "Card_ID" from alter_request where "Request_ID" = Request_ID));
          update debit_account
          set "Overdraft" = "Overdraft" + alter_amount
          where "Account_ID" = account_id;
      elsif request = 'Overdraft Decrease' THEN
          account_id := (select "Debit_ID" from cards where "Card_ID" = (select "Card_ID" from alter_request where "Request_ID" = Request_ID));
          update debit_account
          set "Overdraft" = "Overdraft" - alter_amount
          where "Account_ID" = account_id;
      end if;
    end if;
end;
$$;
----------
----------

grant execute on procedure customer_creation(entry_firstname varchar(255), entry_lastname varchar(255), entry_address varchar(255), 
entry_contacts varchar(255), entry_password varchar(255)) to customer;

grant execute on procedure account_creation(username varchar(255), requested_account_type varchar(255)) to customer;
grant execute on procedure apply_loans(Account_ID Integer, Loan_Amount Money) to customer;
grant execute on procedure customer_balance_transfer(payee_card_id Integer, payer_card_id Integer, value3 Money) to customer;
grant execute on procedure pay_off_loan(Loan_ID Integer, Money_Paid Money) to customer;
grant execute on procedure requests_for_account(Card_ID Integer, Request Varchar(20), Alter_Value Money) to customer;

---------
--------

grant execute on procedure loan_acceptance(loan_id Integer, loan_status varchar(25)) to manager;
grant execute on procedure employee_creation(entry_firstname varchar(255), entry_lastname varchar(255), entry_address varchar(255), 
entry_rank Integer, entry_password varchar(255)) to manager;
grant execute on procedure request_acceptance(Request_ID Integer, New_Request_Status Varchar(20)) to manager;

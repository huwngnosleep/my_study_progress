-- drop tables

-- drop table inventory_fact;
-- drop table branch_plant_dim;
-- drop table cust_vendor_dim;
-- drop table item_master_dim;
-- drop table addr_cat_code1;
-- drop table addr_cat_code2;
-- drop table item_cat_code1;
-- drop table item_cat_code2;
-- drop table company_dim;
-- drop table zip_codes;
-- drop table date_dim;
-- drop table trans_type_dim;

-- drop table Currency_Dim;

CREATE TABLE Currency_Dim (Currency_ID VarChar(3),Exchange_Rate Decimal(8,2));

-- create address category code...
create table addr_cat_code1(
  AddrCatCodeKey  integer not null,
  AddrCatCodeId   varchar(4) not null,
  AddrCatDesc     varchar(30) not null,
  constraint      addr_cat_code1_PK Primary Key(AddrCatCodeKey)
);
  
create table addr_cat_code2(
  AddrCatCodeKey  integer not null,
  AddrCatCodeId   varchar(4) not null,
  AddrCatDesc     varchar(30) not null,
  constraint      addr_cat_code2_PK Primary Key(AddrCatCodeKey)
);

create table item_cat_code1(
  ItemCatCodeKey  integer not null,
  ItemCatCodeId   varchar(4) not null,
  ItemCatDesc     varchar(30) not null,
  constraint      item_cat_code1_PK Primary Key(ItemCatCodeKey)
);

create table item_cat_code2(
  ItemCatCodeKey  integer not null,
  ItemCatCodeId   varchar(4) not null,
  ItemCatDesc     varchar(30) not null,
  constraint      item_cat_code2_PK Primary Key(ItemCatCodeKey)
);

create table zip_codes(
  ZipKey          integer not null,
  ZipCity         varchar(20) not null,
  ZipState	  varchar(2) not null,
  ZipZip          integer,
  ZipConsec       integer,   -- number of consecutive zip codes...
  ZipWeight       integer,   -- weight rating for zip code genreation
  constraint      zip_codes_PK Primary Key(ZipKey)
);

create table date_dim(
  DateKey      integer not Null, 
  DateJulian   integer not Null,  -- julian date in the format of yyyy-mm-ddd
  CalDay       integer not Null check (CalDay >= 0 and CalDay <= 31),  -- from 1 to 31
  CalMonth     integer not Null check (CalMonth >= 0 and CalMonth <= 12),  -- from 1 to 12
  CalQuarter   integer not Null check (CalQuarter >= 0 and CalQuarter <= 4),  -- from 1 to 4
  CalYear      integer not Null check (CalYear >= 1900 and CalYear <= 2100),  -- valid for 1900 to 2100
  DayOfWeek    integer not Null check (DayOfWeek >= 0 and DayOfWeek <= 6),  -- 1 to 7 1 is Sunday, 2 is monday...
  FiscalYear   integer not Null,
  FiscalPeriod integer not Null,
  constraint   date_dim_pk Primary Key(DateKey)
);

create table trans_type_dim(
  TransTypeKey       integer not null check (TransTypeKey >= 1 and TransTypeKey <= 5),
  TransTypeCodeId    varchar(2) not null,
  TransDescription   varchar(30) not null,
  constraint         trans_type_pk Primary Key(TransTypeKey)
 -- TransTypeKey = 1 then TransTypeCodeId = 'IA' (inventory adjustment)
 -- TransTypeKey = 2 then TransTypeCodeId = 'IT' (inventory transfer)
 -- TransTypeKey = 3 then TransTypeCodeId = 'IS' (inventory simple issue)
 -- TransTypeKey = 4 then TransTypeCodeId = 'OV' (purchase order receipt)
 -- TransTypeKey = 5 then TransTypeCodeId = 'AR' (sales order shipment)   
);

create table cust_vendor_dim(
  CustVendorKey   integer not null,
  AddrBookId      integer not null unique,
  Name            varchar(30) not null,
  Address         varchar(30) not null,
  City 	      varchar(20) not null,
  State           varchar(2) not null,
  PrimZip         integer not null,
  Zip             varchar(10) not null,
  Country         varchar(3) default 'USA',
  AddrCatCode1    integer,
  AddrCatCode2    integer,
  constraint cust_vend_dim_pk Primary Key(CustVendorKey),
  constraint cust_vend_CatCode1_FK Foreign Key(AddrCatCode1) references addr_cat_code1 (AddrCatCodeKey),
  constraint cust_vend_CatCode2_FK Foreign Key(AddrCatCode2) references addr_cat_code2 (AddrCatCodeKey)
);
  
create table item_master_dim(
  ItemMasterKey  integer not null,
  ShortItemId    integer not null,
  SecondItemId   varchar(30) not null,
  ThirdItemId    varchar(30) not null,
  ItemCatCode1   integer,
  ItemCatCode2   integer,
  ItemDesc       varchar(30),
  UOM            varchar(3),
  constraint item_master_dim_pk Primary Key(ItemMasterkey),
  constraint item_master_CatCode1_FK Foreign Key(ItemCatCode1) references item_cat_code1 (ItemCatCodeKey),
  constraint item_master_CatCode2_FK Foreign Key(ItemCatCode2) references item_cat_code2 (ItemCatCodeKey),
  constraint UniqueShortItemId UNIQUE (ShortItemId)
);

create table company_dim(
  CompanyKey     integer,
  CompanyId      varchar(5) not null,
  CompanyName    varchar(30) not null,
  CurrencyCode   varchar(5) not null,
  CurrencyDesc   varchar(30)not null,
  constraint company_dim_pk Primary Key (CompanyKey)
);

create table branch_plant_dim(
  BranchPlantKey integer,
  BranchPlantId  varchar(12) not null,
  CompanyKey     integer,
  CarryingCost   decimal(3,2) not null,
  CostMethod     varchar(2) not null,
  BPName         varchar(30),
  constraint branch_plant_dim_pk Primary Key (BranchPlantKey),
  constraint branch_plant_CompanyId_FK Foreign Key(CompanyKey) references company_dim (CompanyKey)
);

create table inventory_fact(
  InventoryKey    integer AUTO_INCREMENT,  -- AUTO INCREMENT used for fact table
  BranchPlantKey  integer not NULL,
  DateKey         integer not NULL,
  ItemMasterKey   integer not NULL,
  TransTypeKey    integer not NULL,
  CustVendorKey   integer,
  UnitCost        decimal(12,4),
  Quantity        decimal(9,4),
  ExtCost         decimal(14,2),
  constraint inv_fact_PK PRIMARY Key(InventoryKey),
  constraint inv_fact_Branch_Plant_FK Foreign Key(BranchPlantKey) references branch_plant_dim (BranchPlantKey),
  constraint inv_fact_DateId_FK Foreign Key(DateKey) references Date_dim (DateKey),
  constraint inv_fact_CustVendorKey_FK Foreign Key(CustVendorKey) references cust_vendor_dim (CustVendorKey),
  constraint inv_fact_TransTypeId_FK Foreign Key(TransTypeKey) references trans_type_dim (TransTypeKey),
  constraint inv_fact_ShortItemId_FK Foreign Key(ItemMasterKey) references item_master_dim (ItemMasterKey) 
);
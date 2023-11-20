-----------------------------------------------------------------------------------------------
-- STEP ONE --
-----------------------------------------------------------------------------------------------

CREATE DATABASE housing_data_cleaning;
USE housing_data_cleaning;

-----------------------------------------------------------------------------------------------
-- STEP TWO --
-----------------------------------------------------------------------------------------------

-- IMPORT FILE USING MYSQL TABLE DATA IMPORT WIZARD --

-----------------------------------------------------------------------------------------------
-- STEP THREE (VIEW DATA IMPORTED) --
-----------------------------------------------------------------------------------------------

SELECT * FROM housing_data_cleaning.housing_data;

-----------------------------------------------------------------------------------------------
-- PROJECT:- Cleaning Data in SQL Queries using the Top 1000 rows-- 
-- CLEANING ONE: Standardize Date Format --
-----------------------------------------------------------------------------------------------

select saledate,str_to_date(saledate, "%m/%d/%Y %H/%i/%s")
FROM housing_data_cleaning.housing_data;

Set sql_safe_updates = 0;
Update housing_data_cleaning.housing_data
Set saledate = str_to_date(saledate, "%m/%d/%Y %H/%i/%s");
set sql_safe_updates = 1;

Set sql_safe_updates = 0;
Update housing_data_cleaning.housing_data
set saledate = convert(saledate, Date);
set sql_safe_updates = 1;

select saledate from housing_data_cleaning.housing_data;

-----------------------------------------------------------------------------------------------
-- PROJECT:- Cleaning Data in SQL Queries using the Top 1000 rows-- 
-- CLEANING TWO: Populate Property Address data --
-----------------------------------------------------------------------------------------------

SELECT PropertyAddress 
FROM housing_data_cleaning.housing_data
where PropertyAddress is null;

select *
FROM housing_data_cleaning.housing_data
where uniqueid IN (6993,43071,5805,5806) 
order by parcelid;

select ha.ParcelID,ha.PropertyAddress,hb.ParcelID,hb.PropertyAddress,
ifnull(ha.PropertyAddress,hb.PropertyAddress) as Populated_Address
FROM housing_data_cleaning.housing_data ha
jOIN housing_data_cleaning.housing_data hb
on ha.ParcelID=hb.ParcelID
and ha.UniqueID <> hb.UniqueID
where ha.PropertyAddress is null;


Set sql_safe_updates = 0;
UPDATE housing_data_cleaning.housing_data ha
LEFT JOIN housing_data_cleaning.housing_data hb
on ha.ParcelID=hb.ParcelID
and ha.UniqueID <> hb.UniqueID
SET ha.PropertyAddress = ifnull(ha.PropertyAddress,hb.PropertyAddress)
where ha.PropertyAddress is null;
set sql_safe_updates = 1;


-----------------------------------------------------------------------------------------------
-- PROJECT:- Cleaning Data in SQL Queries using the Top 1000 rows-- 
-- CLEANING THREE: Breaking out Address into Individual Columns (Address, City, State) --
-----------------------------------------------------------------------------------------------

SELECT PropertyAddress 
FROM housing_data_cleaning.housing_data;
-- where PropertyAddress is null
-- order by PercelID;

Select
substring(propertyaddress,1, Locate(',',propertyaddress)-1) as Address,
substring(propertyaddress, Locate(',',propertyaddress)+1, length(Propertyaddress)) as City
FROM housing_data_cleaning.housing_data;

Alter Table housing_data_project
Add Address Varchar(250);

Set sql_safe_updates = 0;
UPDATE housing_data
Set Address = substring(propertyaddress,1, Locate(',',propertyaddress)-1);
set sql_safe_updates = 1;

Alter Table housing_data
Add City Varchar(250);

Set sql_safe_updates = 0;
UPDATE housing_data
Set City = substring(propertyaddress, Locate(',',propertyaddress)+1, length(Propertyaddress));
set sql_safe_updates = 1;

Select * From housing_data_cleaning.housing_data;

----------------------------------
-- SEPERATING THE OWNERADDRESS ---
----------------------------------

Select OwnerAddress From housing_data_cleaning.housing_data;

Select
substring_index(OwnerAddress,',',1) as OwnerAddress1,
substring_index(substring_index(OwnerAddress,',',2), ',',-1) as OwnerCity,
substring_index(substring_index(OwnerAddress,',',3), ',',-1) as OwnerState
From housing_data_cleaning.housing_data;


Alter Table housing_data
Add OwnerAddress1 Varchar(250);

Set sql_safe_updates = 0;
UPDATE housing_data
Set OwnerAddress1 = substring_index(OwnerAddress,',',1);
set sql_safe_updates = 1;

Alter Table housing_data
Add OwnerCity Varchar(250);

Set sql_safe_updates = 0;
UPDATE housing_data
Set OwnerCity = substring_index(substring_index(OwnerAddress,',',2), ',',-1);
set sql_safe_updates = 1;

Alter Table housing_data
Add OwnerState Varchar(250);

Set sql_safe_updates = 0;
UPDATE housing_data
Set OwnerState = substring_index(substring_index(OwnerAddress,',',3), ',',-1);
set sql_safe_updates = 1;

Select * From housing_data_cleaning.housing_data;


-----------------------------------------------------------------------------------------------
-- PROJECT:- Cleaning Data in SQL Queries using the Top 1000 rows-- 
-- CLEANING FOUR: Change Y and N to Yes and No in "Sold as Vacant" field --
-----------------------------------------------------------------------------------------------

Select distinct soldasvacant, count(soldasvacant)
From housing_data_cleaning.housing_data
Group by 1
Order by 2;

Select soldasvacant,
Case when soldasvacant = 'Y' then 'Yes'
	when  soldasvacant = 'N' then 'No'
    Else  Soldasvacant
    End Sold_As_Vacant
From housing_data_cleaning.housing_data;

Set sql_safe_updates = 0;
UPDATE housing_data
Set soldasvacant = Case when soldasvacant = 'Y' then 'Yes'
	when  soldasvacant = 'N' then 'No'
    Else  Soldasvacant
    End;
set sql_safe_updates = 1;

Select distinct soldasvacant, count(soldasvacant)
From housing_data_cleaning.housing_data
Group by 1
Order by 2;

-----------------------------------------------------------------------------------------------
-- PROJECT:- Cleaning Data in SQL Queries using the Top 1000 rows-- 
-- CLEANING FIVE: Delete Unused Columns --
-----------------------------------------------------------------------------------------------

Select * From housing_data_cleaning.housing_data;

Alter Table housing_data_cleaning.housing_data
Drop column PropertyAddress, Drop OwnerAddress, Drop TaxDistrict;

-----------------------------------------------------------------------------------------------
-- PROJECT:- Cleaning Data in SQL Queries using the Top 1000 rows-- 
-- CLEANING Six: Format LandUse Column into Proper Case--
-----------------------------------------------------------------------------------------------

Select Landuse From housing_data_cleaning.housing_data;

Select
CONCAT(UCASE(SUBSTRING(`LandUse`, 1, 1)), LOWER(SUBSTRING(`LandUse`, 2))) as LandUse
From housing_data_cleaning.housing_data;

Set sql_safe_updates = 0;
UPDATE housing_data
Set LandUse = CONCAT(UCASE(SUBSTRING(`LandUse`, 1, 1)), LOWER(SUBSTRING(`LandUse`, 2)));
set sql_safe_updates = 1;

Select Landuse From housing_data_cleaning.housing_data;
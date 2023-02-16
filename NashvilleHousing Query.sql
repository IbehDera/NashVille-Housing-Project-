Select *
from Portfolio.dbo.[Nashville Project]
---------------------------------------------------------------------------------------------------
--Check PropertyAddress Null values
Select *
From Portfolio.dbo.[Nashville Project]
Where PropertyAddress is null
--Use the ParcelID and UniqueID to populate the PropertyAddress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.[Nashville Project] a
JOIN Portfolio.dbo.[Nashville Project] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.[Nashville Project] a
JOIN Portfolio.dbo.[Nashville Project] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--Confirm that there are no more null values
select *
from Portfolio.dbo.[Nashville Project]
Where PropertyAddress is null
-----------------------------------------------------------------------------------------------------------------------------
--The Owner and Property Address have similar details, split the details for easy understanding
Select OwnerAddress, PropertyAddress
from Portfolio.dbo.[Nashville Project]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Portfolio.dbo.[Nashville Project]

--create a new column for the address
ALTER TABLE Portfolio.dbo.[Nashville Project]
Add PropertySplitAddress Nvarchar(255);

Update Portfolio.dbo.[Nashville Project]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--create a new column for the city
ALTER TABLE Portfolio.dbo.[Nashville Project]
Add PropertySplitCity Nvarchar(255);


Update Portfolio.dbo.[Nashville Project]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--confirm that the changes were made
Select *
from Portfolio.dbo.[Nashville Project]

--split OwnerAddress
Select OwnerAddress
From Portfolio.dbo.[Nashville Project]
where OwnerAddress is null

--use parsename function to split by the delimiters
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio.dbo.[Nashville Project]

--name the splited columns properly 
ALTER TABLE Portfolio.dbo.[Nashville Project]
Add OwnerSplitAddress Nvarchar(255)

ALTER TABLE Portfolio.dbo.[Nashville Project]
Add OwnerCity Nvarchar(255);

ALTER TABLE Portfolio.dbo.[Nashville Project]
Add OwnerState Nvarchar(255);

Update Portfolio.dbo.[Nashville Project]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Update Portfolio.dbo.[Nashville Project]
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Update Portfolio.dbo.[Nashville Project]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
--confirm changes 
Select *
From Portfolio.dbo.[Nashville Project]

--Drop columns that will not be used to draw insight
Select *
From Portfolio.dbo.[Nashville Project]

ALTER TABLE Portfolio.dbo.[Nashville Project]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate, Bedrooms, FullBath, HalfBath

--confirm changes
Select *
From Portfolio.dbo.[Nashville Project]

--Remove duplicates to avoid inaccurate conclusion 
WITH CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio.dbo.[Nashville Project]
)
Delete
From CTE
Where row_num > 1

--confirm the changes
WITH CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio.dbo.[Nashville Project]
)
Select *
From CTE
Where row_num > 1
Order by PropertySplitAddress

--Check final Table
Select *
From Portfolio.dbo.[Nashville Project]
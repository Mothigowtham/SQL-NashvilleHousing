/*
Cleaning Data in SQL Queries
*/

select * 
from Project..housing



-----------------------------------------------------------------------------------------------------------------------

-- Standardize date format
-- Coverting the datatype of SaleDate from  datetime ---> date;
-- Using CONVERT Function


Select SaleDate, CONVERT(date, SaleDate)
From Project..housing


UPDATE project..housing
SET SaleDate = CONVERT(date, SaleDate)


ALTER TABLE Project..housing
ADD Sale_Date Date

UPDATE Project..housing
SET Sale_Date = CONVERT(date, SaleDate)



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- Spliting Property Address ---> Property_split_Address AND Property_split_city
-- Using SUBSTRING Function



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Project..housing AS a
JOIN Project..housing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where b.PropertyAddress is null 


UPDATE b
SET PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
From Project..housing AS a
JOIN Project..housing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where b.PropertyAddress is null 


Select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Property_split_Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) AS Property_split_city
From Project..housing


ALTER TABLE Project..housing
ADD Property_split_Address NVARCHAR(255)


UPDATE Project..housing
SET Property_split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE Project..housing
ADD Property_split_city NVARCHAR(255)


UPDATE Project..housing
SET Property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- Breaking OwnerAddress ---> Owner_split_Address, Owner_split_city, Owner_split_state
-- Using PARSENAME Function


 
Select OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Owner_split_Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Owner_split_city,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Owner_split_state
From Project..housing
 

ALTER TABLE Project.dbo.housing
ADD Owner_split_Address NVARCHAR(255)


ALTER TABLE Project.dbo.housing
ADD Owner_split_city NVARCHAR(255)


ALTER TABLE Project.dbo.housing
ADD Owner_split_state NVARCHAR(255)


UPDATE Project..housing
SET Owner_split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


UPDATE Project..housing
SET Owner_split_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


UPDATE Project..housing
SET Owner_split_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
-- Using CASE Function


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS count
From Project..housing
Group by SoldAsVacant
Order by count


Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
     END
From Project..housing


UPDATE Project..housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Using COMMON TABLE EXPRESSIONS (CTE)



WITH Row_numCTE AS (
Select * , 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY
					 UniqueID
					 ) AS row_num
From Project..housing
)

Select * 
From Row_numCTE
Where row_num > 1





WITH Row_numCTE AS (
Select * , 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY
					 UniqueID
					 ) AS row_num
From Project..housing
)

DELETE
From Row_numCTE
Where row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- using DROP COLUMN Function



ALTER TABLE Project..housing
DROP COLUMN PropertyAddress,
			OwnerAddress,
			TaxDistrict,
			SaleDate;


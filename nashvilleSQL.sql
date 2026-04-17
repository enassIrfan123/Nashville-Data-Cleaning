USE nashvillehousing;

-- DATA CLEANING
-- ------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, SaleDateConverted FROM nashvillehousedata;

SELECT
	SaleDate,
	str_to_date(SaleDate, '%M %e, %Y') AS ConvertedDate
FROM nashvillehousedata;

UPDATE nashvillehousedata
SET SaleDate = str_to_date(SaleDate, '%M %e, %Y');

SET SQL_SAFE_UPDATES = 0; -- updating the safe switch in sql

-- Added an extra
ALTER TABLE nashvillehousedata
ADD SaleDateConverted DATE;

UPDATE nashvillehousedata
SET SaleDateConverted = CAST(SaleDate AS DATE);

-- ---------------------------------------------------------------
-- Populate property address data
SELECT * FROM nashvillehousedata
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Updated the empty values to null for easy use
UPDATE nashvillehousedata
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
		IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousedata AS a
JOIN nashvillehousedata AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE nashvillehousedata AS a 
JOIN nashvillehousedata AS b 
    ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL OR a.PropertyAddress = '';

-- ---------------------------------------------------------
-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS ( Address,City, State)

SELECT PropertyAddress
FROM nashvillehousedata;

-- Put -1 so that it can include one less character excluding the coma in the results
SELECT 
	SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1,
	LENGTH(PropertyAddress)) AS City
FROM nashvillehousedata;

ALTER TABLE nashvillehousedata
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashvillehousedata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1);

ALTER TABLE nashvillehousedata
ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousedata
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1,
	LENGTH(PropertyAddress));
    
SELECT PropertySplitAddress,PropertySplitCity
FROM nashvillehousedata;

-- OWNER ADDRESS
SELECT OwnerAddress
FROM nashvillehousedata;

SELECT SUBSTRING_INDEX(OwnerAddress,',',1) AS OwnerSplitAddress
FROM nashvillehousedata;

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1) AS OwnerSplitCity
FROM nashvillehousedata;

SELECT SUBSTRING_INDEX(OwnerAddress,',',-1) AS OwnerSplitState
FROM nashvillehousedata;

-- add in the table
ALTER TABLE nashvillehousedata
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashvillehousedata
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE nashvillehousedata
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashvillehousedata
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1);

ALTER TABLE nashvillehousedata
ADD OwnerSplitState VARCHAR(255);

UPDATE nashvillehousedata
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1);

SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM nashvillehousedata;

SELECT *
FROM nashvillehousedata;

-- ---------------------------------------------------------------------------
-- CHANGE Y and N to Yes and No

SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousedata
GROUP BY SoldAsVacant
Order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVAcant
    END 
FROM nashvillehousedata;

UPDATE nashvillehousedata
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVAcant
    END
;

-- ---------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	row_number() OVER (
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY UniqueID
                ) row_num
FROM nashvillehousedata
)
-- order by ParcelID;

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

DELETE FROM nashvillehousedata 
WHERE UniqueID IN (
    SELECT UniqueID FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM nashvillehousedata
    ) AS temp_table
    WHERE row_num > 1
);

                

-- --------------------------------------------------
-- Delete unused columns


ALTER TABLE nashvillehousedata 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate; 

SELECT * FROM nashvillehousedata;


-- MOving the columns for better reading
ALTER TABLE nashvillehousedata
MODIFY COLUMN SaleDateConverted DATE AFTER ParcelID;

ALTER TABLE nashvillehousedata
MODIFY COLUMN PropertySplitAddress VARCHAR(255) AFTER SaleDateConverted;

ALTER TABLE nashvillehousedata
MODIFY COLUMN PropertySplitCity VARCHAR(255) AFTER PropertySplitAddress ;

CREATE VIEW Nashville_Clean_View AS
SELECT 
    UniqueID, 
    SaleDateConverted, 
    PropertySplitAddress, 
    PropertySplitCity, 
    OwnerSplitAddress,
    OwnerSplitCity,
    OwnerSplitState,
    ParcelID, 
    SalePrice, 
    LegalReference, 
    SoldAsVacant
FROM nashvillehousedata;

SELECT * FROM Nashville_Clean_View;


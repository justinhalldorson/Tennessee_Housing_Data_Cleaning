

SELECT *
FROM Nashville_Housing_Data nhd


-- Convert blank Property Addresses to NULL

UPDATE Nashville_Housing_Data 
SET PropertyAddress = CASE PropertyAddress WHEN '' THEN NULL ELSE PropertyAddress END


-- Standardize Sale Date

SELECT SaleDateConverted, CONVERT(SaleDate, Date)
FROM Nashville_Housing_Data nhd 

UPDATE Nashville_Housing_Data
SET SaleDate = CONVERT(SaleDate, Date)

ALTER TABLE Nashville_Housing_Data 
ADD SaleDateConverted Date

UPDATE Nashville_Housing_Data
SET SaleDateConverted = CONVERT(SaleDate, Date)


-- Populate Property Address data

SELECT * 
FROM Nashville_Housing_Data nhd 
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) 
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL


-- Breaking Address into individual columns

SELECT PropertyAddress
FROM Nashville_Housing_Data nhd


SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as StreetAddress, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) as City
FROM Nashville_Housing_Data nhd


ALTER TABLE Nashville_Housing_Data
ADD PropertySplitAddress varchar(255)

UPDATE Nashville_Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1)


ALTER TABLE Nashville_Housing_Data
ADD PropertySplitCity varchar(255)

UPDATE Nashville_Housing_Data
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress))


SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) as State
FROM Nashville_Housing_Data nhd

ALTER TABLE Nashville_Housing_Data
ADD PropertySplitState varchar(255)

UPDATE Nashville_Housing_Data
SET PropertySplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)


-- Change Y and N to 'Yes' and 'No' in SoldAsVacant field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM Nashville_Housing_Data nhd
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE 	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
FROM Nashville_Housing_Data nhd


UPDATE Nashville_Housing_Data
SET SoldAsVacant = 
CASE 	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END


-- Remove duplicates

WITH RowNumCTE AS(
		
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num 


FROM Nashville_Housing_Data nhd
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
		
DELETE CTE1 FROM RowNumCTE CTE1
INNER JOIN RowNumCTE CTE2 
ON row_num > 1


-- Remove unused columns

ALTER TABLE Nashville_Housing_Data
DROP OwnerAddress,
DROP TaxDistrict,
DROP PropertyAddress,
DROP SaleDate

		
		
		
		
		
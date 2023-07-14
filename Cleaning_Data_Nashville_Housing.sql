/*
Cleaning Data in SQL Queries
*/

SELECT * 
FROM MyPortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate CONVERT (Date, SaleDate)
FROM MyPortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data

SELECT PropertyAddress
FROM MyPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MyPortfolioProject.dbo.NashvilleHousing a
JOIN MyPortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MyPortfolioProject.dbo.NashvilleHousing a
JOIN MyPortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM MyPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN (PropertyAddress))AS Address
FROM MyPortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN (PropertyAddress))



SELECT OwnerAddress
FROM MyPortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From MyPortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT SoldAsVacant,
COUNT (SoldAsVacant)
From MyPortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 1,2

SELECT 
CASE WHEN SoldAsVacant = 0 THEN  'No' WHEN SoldAsVacant = 1 THEN  'Yes' END,
COUNT (SoldAsVacant)
From MyPortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 1,2

UPDATE MyPortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN  'No' 
WHEN SoldAsVacant = 1 THEN  'Yes' 
ELSE SoldAsVacant 
END



-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER BY 
				UniqueID
				) row_num
FROM MyPortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- Delete Unused Columns


SELECT * 
FROM MyPortfolioProject.dbo.NashvilleHousing


ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

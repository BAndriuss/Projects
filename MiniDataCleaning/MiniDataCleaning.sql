SELECT *
FROM PortfolioProjects..NashvilleHousing
order by 2

-- Standardizing Date Format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)




-- Populating Property Address Data

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM PortfolioProjects..NashvilleHousing A
JOIN PortfolioProjects..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress) -- ISNULL populates null values (null columns, populated columns)
FROM PortfolioProjects..NashvilleHousing A
JOIN PortfolioProjects..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL





-- Breaking Out Address into Individual Columns (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress) ) as Address
FROM PortfolioProjects..NashvilleHousing

--ADDING SPLIT ADDRESS
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--ADDING SPLIT CITY
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress) )





SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.' ), 3) as Address
,PARSENAME(REPLACE(OwnerAddress,',', '.' ), 2) as City
,PARSENAME(REPLACE(OwnerAddress,',', '.' ), 1) as State
FROM PortfolioProjects..NashvilleHousing

-- ADDING OWNER SPLIT ADDRESS
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',', '.' ), 3)

-- ADDING OWNER SPLIT CITY
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',', '.' ), 2)

-- ADDING OWNER SPLIT STATE
ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',', '.' ), 1)




-- Changing Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
END






-- REMOVING DUPLICATES
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProjects..NashvilleHousing
)
--Use DELETE instead of SELECT to delete
SELECT *
FROM RowNumCTE
Where row_num > 1


SELECT *
FROM PortfolioProjects..NashvilleHousing

--Deleting Unused Columns

--ALTER TABLE PortfolioProjects..NashvilleHousing
--DROP COLUMN LandUse
/*

Nashville Housing Data Cleaning in SQL Queries

Skills used: Joins, CTE's, Substrings, Windows Functions, Case Functions, Converting Data Types
 

*/

Select *
From PortfolioProject..NashvilleHousingData


-- Standardize Date Format


ALTER TABLE NashvilleHousingData
ADD SaleDate2 Date;

UPDATE NashvilleHousingData
SET SaleDate2 = CONVERT(Date,SaleDate)

Select SaleDate2
From NashvilleHousingData


-- Populate Property Address Data


Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From PortfolioProject..NashvilleHousingData A
Join PortfolioProject..NashvilleHousingData B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From PortfolioProject..NashvilleHousingData A
Join PortfolioProject..NashvilleHousingData B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


Select *
From PortfolioProject..NashvilleHousingData
Where PropertyAddress is null


--Splitting the Property Address (Address, City)


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD Property_Address nvarchar(255);

UPDATE NashvilleHousingData
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE NashvilleHousingData
ADD Property_City nvarchar(255);

UPDATE NashvilleHousingData
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


--Splitting the Owner Address (Address, City, State)


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD Owner_Address nvarchar(255);

UPDATE NashvilleHousingData
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER TABLE NashvilleHousingData
ADD Owner_City nvarchar(255);

UPDATE NashvilleHousingData
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD Owner_State nvarchar(255);

UPDATE NashvilleHousingData
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Changing 'Y' to 'Yes' and 'N' to 'No' in the "Sold As Vacant" Column


Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
END
From PortfolioProject..NashvilleHousingData

UPDATE PortfolioProject..NashvilleHousingData
SET SoldAsVacant = 
	CASE
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	END


--Removing Duplicate Data 


WITH RowNumCTE As (
Select *,
	ROW_NUMBER () OVER (
	PARTITION BY 
				ParcelID,
				PropertyAddress,
				LegalReference
	Order By UniqueID) RowNum
From PortfolioProject..NashvilleHousingData
)
DELETE
From RowNumCTE
Where RowNum > 1


-- Deleting Unused Columns 

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict


Select *
From PortfolioProject..NashvilleHousingData



/*     Cleaning Data with SQL Queries      */

SELECT *
FROM portfolio_project..Real_Estate_sales_nashville

--------------------------------- Standardize Date Format----------------------------

ALTER TABLE Real_Estate_sales_nashville
Add SaleDateConverted Date;

Update Real_Estate_sales_nashville
SET SalesDateConverted = CONVERT(Date,SaleDate)


-------------------------------- Populate Property Address data-----------------------

Select *
From portfolio_project..Real_Estate_sales_nashville



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project..Real_Estate_sales_nashville a
JOIN portfolio_project..Real_Estate_sales_nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project..Real_Estate_sales_nashville a
JOIN portfolio_project..Real_Estate_sales_nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------- Breaking out Adress into individual columns(Address, City, State)------------------------
SELECT *
FROM portfolio_project..Real_Estate_sales_nashville


SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) +1  , LEN(PropertyAddress))  as City
	FROM portfolio_project..Real_Estate_sales_nashville


ALTER TABLE portfolio_project..Real_Estate_sales_nashville
Add PropertyAdressOnly varchar(255);

Update portfolio_project..Real_Estate_sales_nashville
SET PropertyAdressOnly = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1)

ALTER TABLE portfolio_project..Real_Estate_sales_nashville
Add PropertyCityOnly varchar(255);

Update portfolio_project..Real_Estate_sales_nashville
SET PropertyCityOnly = SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) +1  , LEN(PropertyAddress))

---Doing Address splitting for OwnerAddress in a different way

SELECT OwnerAddress
FROM portfolio_project..Real_Estate_sales_nashville


SELECT PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3) AS OwnerAddressOnly,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)AS OwnerCityOnly,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1) AS OwnerStateOnly
FROM portfolio_project..Real_Estate_sales_nashville

ALTER TABLE portfolio_project..Real_Estate_sales_nashville
Add OwnerAddressOnly varchar(255);

Update portfolio_project..Real_Estate_sales_nashville
SET OwnerAddressOnly = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)


ALTER TABLE portfolio_project..Real_Estate_sales_nashville
Add OwnerCityOnly varchar(255);

Update portfolio_project..Real_Estate_sales_nashville
SET OwnerCityOnly = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)


ALTER TABLE portfolio_project..Real_Estate_sales_nashville
Add OwnerStateOnly varchar(255);

Update portfolio_project..Real_Estate_sales_nashville
SET OwnerStateOnly = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)



--------------------------------Changing Y and N to Yes or No in "SoldAsVacant" collumn-----------------

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM portfolio_project..Real_Estate_sales_nashville
GROUP BY SoldAsVacant
order by 2


SELECT SoldAsVacant,
	CASE when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
	END
FROM portfolio_project..Real_Estate_sales_nashville
GROUP BY SoldAsVacant


UPDATE portfolio_project..Real_Estate_sales_nashville
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						ELSE SoldAsVacant
					END	



------------------------------------------Removing Duplicates---------------------------------------------------


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY 
			ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress
		ORDER BY UniqueID
	) row_num
FROM portfolio_project..Real_Estate_sales_nashville
)

DELETE
FROM RowNumCTE
Where  row_num > 1



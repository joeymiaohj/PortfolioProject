/*
Cleaning data in SQL queries
*/
select * 
from NashvilleHousing$

-----------------------------------------------------------
---Standadise Date Format

select SaleDate,CONVERT(DATE,SaleDate)
from NashvilleHousing$

update NashvilleHousing$
set SaleDate = CONVERT(DATE,SaleDate)

ALTER Table NashvilleHousing$
ADD SalesDateConverted DATE

update NashvilleHousing$
set SalesDateConverted = CONVERT(Date,SaleDate)

select salesDateConverted
from NashvilleHousing$

---------------------------------------------------------
----Property Address
select PropertyAddress
from NashvilleHousing$
--where PropertyAddress is null
order by parcelID

select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing$ a
join NashvilleHousing$ b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
where a.PropertyAddress is null

update a 
set propertyAddress = ISNULL(a.propertyAddress,b.propertyAddress)
from NashvilleHousing$ a
join NashvilleHousing$ b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
where a.PropertyAddress is null

---------------------------------------------------------
----Breaking out Address into individual columns (Address,City, State)

select PropertyAddress
from NashvilleHousing$
--where PropertyAddress is null
--order by parcelID


select SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address
from NashvilleHousing$

Alter Table NashvilleHousing$
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing$
set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing$
Add PropertySplitCity nvarchar(255);

update NashvilleHousing$
set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) 


select 
parsename(Replace(OwnerAddress,',','.'),3),
parsename(Replace(OwnerAddress,',','.'),2),
parsename(Replace(OwnerAddress,',','.'),1)
from NashvilleHousing$

Alter Table NashvilleHousing$
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing$
set OwnerSplitAddress = parsename(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing$
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing$
set OwnerSplitCity = parsename(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing$
Add OwnerSplitState nvarchar(255);

update NashvilleHousing$
set OwnerSplitState = parsename(Replace(OwnerAddress,',','.'),1)

-----------------------------------------------------------
---Change Y and N to yes and no in 'Sold as Vacant' field
select distinct SoldAsVacant, COUNT(SoldAsVacant)
from NashvilleHousing$
group by SoldAsVacant
order by 2

select SoldAsVacant, 
CASE	WHEN	SoldAsVacant = 'Y' THEN 'Yes'
		WHEN	SoldAsVacant = 'N' THEN 'No'
		ELSE	SoldAsVacant
		END
from NashvilleHousing$

UPDATE NashvilleHousing$
SET SoldAsVacant = CASE	WHEN	SoldAsVacant = 'Y' THEN 'Yes'
						WHEN	SoldAsVacant = 'N' THEN 'No'
						ELSE	SoldAsVacant
						END

---------------------------------------------------------------
------Remove duplicate

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID)	row_num
from NashvilleHousing$
)
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress

---------------------------------------------------------------
------Delete Unused Columns

select *
from NashvilleHousing$

ALTER TABLE NashvilleHousing$
Drop	Column	OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing$
Drop	Column	SaleDate

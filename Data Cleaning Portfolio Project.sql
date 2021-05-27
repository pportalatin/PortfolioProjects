/*

Cleaning Data in SQL Queries

*/

Select *
from [dbo].[NashvilleHousing]


----- Srandardize SalesDate -----

Select SaleDateConverted, cast(SaleDate as Date)
from [dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
set SaleDate = cast(SaleDate as Date)

Alter table [dbo].[NashvilleHousing]
ADD SaleDateConverted Date;

UPDATE [dbo].[NashvilleHousing]
set SaleDateConverted = cast(SaleDate as Date)


----- Populate Property adress data -----

Select *
from [dbo].[NashvilleHousing]
--where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] as a
join [dbo].[NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is Null

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] as a
join [dbo].[NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null


----- Breaking down Address into Individual Columns( Address, City, State) -----

Select PropertyAddress
from [dbo].[NashvilleHousing]


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

from [dbo].[NashvilleHousing]

Alter table [dbo].[NashvilleHousing]
ADD PropertySplitAddress nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

Alter table [dbo].[NashvilleHousing]
ADD PropertySplitCity nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


 ----- Break Down Owners Address into seperate categories -----

 select OwnerAddress
 from [dbo].[NashvilleHousing]

 Select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
 from [dbo].[NashvilleHousing]


Alter table [dbo].[NashvilleHousing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

Alter table [dbo].[NashvilleHousing]
ADD OwnerCity nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

Alter table [dbo].[NashvilleHousing]
ADD OwnerState nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
set OwnerState =  PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



----- Change Y and N to Yes and No in "Sold as Vacant" field -----

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from [dbo].[NashvilleHousing]
group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'Yes'
	   else SoldAsVacant
	   end
from [dbo].[NashvilleHousing]


Update [dbo].[NashvilleHousing]
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'Yes'
	   else SoldAsVacant
	   end



----- Remove Duplicates -----

With RowNumCTE as(
select *,
	ROW_NUMBER() Over(
	Partition by ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference
	Order BY UniqueID
					) as row_num

from [dbo].[NashvilleHousing]
)

select * 
from RowNumCTE
where row_num > 1
ORder by PropertyAddress

----- Delete Unused Columns -----


select *
 from [dbo].[NashvilleHousing]

 Alter Table [dbo].[NashvilleHousing]
 Drop Column OwnerAddress, ProperyAddress
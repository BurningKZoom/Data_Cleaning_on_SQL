-- Changing Date format

Select SaleDate, cast(SaleDate as date) as WantedSaleDate
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
alter column SaleDate date -- Change to wanted format

--------------------------------------------------------------------------------------------------------------------------------------------
-- Finding the missing Property Address data

Select * 
from PortfolioProject..NashvilleHousing
where PropertyAddress is null  -- 
order by ParcelID -- The result is showing that there are null values in the PropertyAddress column which can cause a problem especially in the Housing industry

select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID  -- The same Parcel ID means that it should have the same address
	and a.[UniqueID ] <> b.[UniqueID ]-- Same ParcelID but different UniqueID means that it's the same house but just different transaction 
where a.PropertyAddress is null
order by a.PropertyAddress

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) -- Update the null address with the address that have the same ParcelID
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID  
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------------
-- Extracting each element of the address into columns (Address, City, State)


-- Property Address (There is no State info in the 'PropertyAddress')

select -- Checking whether the query is working as intended or not
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing


Alter table NashvilleHousing -- Creating a blank column for the splited Address data
Add PropertySplitAddress Nvarchar(255)

Alter table NashvilleHousing -- Creating a blank column for the splited City data
Add PropertySplitCity Nvarchar(255)


Update NashvilleHousing -- Updating the blank column with the prepared query
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Update NashvilleHousing -- Updating the blank column with the prepared query
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))


-- Owner's Address

select -- Checking whether the query is working as intended or not
left(OwnerAddress, CHARINDEX(',', [OwnerAddress])-1) as Address,
PARSENAME(REPLACE([OwnerAddress], ',','.'),2) as City,
RIGHT([OwnerAddress], 2) as State
from PortfolioProject..NashvilleHousing


Alter table NashvilleHousing -- Creating a blank column for the splited City data
Add OwnerSplitAddress Nvarchar(255)

Alter table NashvilleHousing -- Creating a blank column for the splited City data
Add OwnerSplitCity Nvarchar(255)

Alter table NashvilleHousing -- Creating a blank column for the splited City data
Add OwnerSplitState Nvarchar(255)


Update NashvilleHousing -- Updating the blank column with the prepared query
set OwnerSplitAddress = LEFT(OwnerAddress, CHARINDEX(',', [OwnerAddress])-1) 

Update NashvilleHousing -- Updating the blank column with the prepared query
set OwnerSplitCity = PARSENAME(REPLACE([OwnerAddress], ',','.'),2)

Update NashvilleHousing -- Updating the blank column with the prepared query
set OwnerSplitState = RIGHT([OwnerAddress], 2) 

--------------------------------------------------------------------------------------------------------------------------------------------
-- Change 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant' field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant -- The result is showing that there are both 'Y', 'N' and 'Yes', 'No' in the field which might cause issue in later analysis

Update NashvilleHousing -- Updating 'Y' to 'Yes' and 'N' to 'No'
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
					end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Removing duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	PARTITION BY parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from PortfolioProject..NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1


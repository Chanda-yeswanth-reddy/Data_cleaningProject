
--start--

select * from datacleaning..housing


--Changing date format--

select SaleDate,convert(date,SaleDate) from datacleaning..housing

alter table housing
add  SaleDateconverted date

update housing
set SaleDateconverted=convert(date,SaleDate)
select SaleDateconverted,convert(date,SaleDate) from datacleaning..housing

--Changing property address/deleting null values--

select * from datacleaning..housing

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,isnull(a.PropertyAddress,b.PropertyAddress)
from datacleaning..housing a
join datacleaning..housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from datacleaning..housing a
join datacleaning..housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Formatting address or splitting where there is a delimiter--

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from datacleaning..housing

alter table housing
add Propertysplitadd varchar(255);

update housing
set Propertysplitadd=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table housing
add Propertysplitcity varchar(255);

update housing
set Propertysplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select * from datacleaning..housing

--Cleaning owner address--

select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from datacleaning..housing

alter table housing
add ownersplitadd varchar(255);

update housing
set ownersplitadd=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table housing
add ownersplitcity varchar(255);

update housing
set ownersplitcity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table housing
add ownersplitstate varchar(255);

update housing
set ownersplitstate=PARSENAME(replace(OwnerAddress,',','.'),1)

select * from datacleaning..housing


--Changing soldorvacant column  boolean to sold/vacant--

select distinct(SoldAsVacant) from datacleaning..housing


select SoldAsVacant,case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant  end
from datacleaning..housing

update housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant  end


--Removing duplicates--

select * from datacleaning..housing

with RowNumCTE as(
select *,ROW_NUMBER() over(partition by ParcelID,PropertyAddress,SaleDate,
SalePrice,LegalReference order by UniqueID) row_num 
from datacleaning..housing
)
delete from RowNumCTE where row_num >1

--Deleteing unnecessary columns--

alter table datacleaning..housing
drop column OwnerAddress,TaxDistrict,PropertyAddress

select * from datacleaning..housing

alter table datacleaning..housing
drop column SaleDate
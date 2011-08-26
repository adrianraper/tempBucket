{* Name: DHL Delivery spreadsheet *}
{* Description: CSV file sent to DHL when you they have to deliver for iLearnIELTS. *}
{* Parameters: $data (which is $api) *}
{if $data->offerID==7}{assign var='package' value='Academic'}{else}{assign var='package' value='General Training'}{/if}
receivers_id	Customer Reference	Receiver Name	House Number	Street Name	Suburb	City	Region	ZIP Code	Country	Phone	Mobile	Package
1	{$data->orderRef}	{$data->name}	{$data->address1}	{$data->address2}	{$data->address3}	{$data->city}	{$data->state}	{$data->ZIP}	{$data->country}	{$data->phone}	{$data->mobile}	{$package}
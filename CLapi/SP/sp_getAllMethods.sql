create or alter proc sp_getAllMethods 
as
begin
	set nocount on;
	select * from dbo.tbl_method;
end
go
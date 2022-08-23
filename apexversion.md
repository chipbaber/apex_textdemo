## Query to Get APEX Version, Patchset and ORDS Version

- Query run on ATP free tier instance

```
select 'APEX' as product, version_no, api_compatibility, case when patch_applied = 'APPLIED'
then (select listagg('Patch ' || to_char(patch_number) || ' (' || patch_version || ') installed on ' || installed_on, ', ')
within group (order by installed_on) as patches from apex_patches) end as applied_patches from apex_release
 union all select 'ORDS' as product, ords.installed_version as version_no, null as api_compatibility, null as applied_patches from dual;
```

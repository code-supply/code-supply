select i.hostname, b.id, b.error, i.klipper_config 
from builds b 
join images i on i.id = b.image_id 
where i.user_id is null
order by b.id

select u.email, b.id, b.error, i.klipper_config 
from builds b 
join images i on i.id = b.image_id 
join users u on u.id = i.user_id
where error is not null

select u.email, i.hostname, b.id, b.error, i.klipper_config 
from builds b 
join images i on i.id = b.image_id 
join users u on u.id = i.user_id
where u.email LIKE :'email' || '%'
order by u.email, b.id

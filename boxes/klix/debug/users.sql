select 
u.email,
count(i.id) as images,
count(b.id) as builds
from users u
left join images i on i.user_id = u.id
left join builds b on b.image_id = i.id
group by u.id
order by images, builds

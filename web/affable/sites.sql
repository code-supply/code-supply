select
s.internal_name,
s.name as site_name,
u.email,
s.inserted_at
from sites s
inner join site_members sm on sm.site_id = s.id
inner join users u on u.id = sm.user_id;

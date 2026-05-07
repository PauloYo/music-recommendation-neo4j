MATCH (target:Music {title: "Blinding Lights"})
MATCH (target)-[:BELONGS_TO]->(g:Genre)<-[:BELONGS_TO]-(recommended:Music)
WHERE recommended.title <> "Blinding Lights"
OPTIONAL MATCH (u)-[listen:LISTENED]->(recommended)
RETURN
    recommended.title AS music,
    count(DISTINCT u) AS usersWhoListened,
    coalesce(sum(listen.times), 0) AS accumulatedListens
ORDER BY accumulatedListens DESC, usersWhoListened DESC, music;

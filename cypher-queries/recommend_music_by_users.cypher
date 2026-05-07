MATCH (:Music {title: "Blinding Lights"})<-[:LIKED]-(u:User)-[:LIKED]->(recommended:Music)
WHERE recommended.title <> "Blinding Lights"
OPTIONAL MATCH (u)-[listen:LISTENED]->(recommended)
RETURN
  recommended.title AS music,
  count(DISTINCT u) AS usersWhoAlsoLiked,
  coalesce(sum(listen.times), 0) AS accumulatedListens
ORDER BY accumulatedListens DESC, usersWhoAlsoLiked DESC, music;

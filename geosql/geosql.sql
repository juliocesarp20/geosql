-- 1
SELECT nm_mun, geom
FROM municipio_mg
WHERE nm_mun LIKE 'Santo%' OR nm_mun LIKE 'Santa%';

-- 2
SELECT ST_length(geom::geography), sigla
FROM rodovia_br
WHERE ST_length(geom::geography) > 100000;

-- 3
SELECT nome, geom
FROM distrito_mg
WHERE igamunicip='Ouro Preto';

-- 4
SELECT DISTINCT nm_mun, m.geom
FROM pista_pouso_mg p
JOIN municipio_mg m
ON ST_CONTAINS(ST_Transform(m.geom, 4674), ST_Transform(p.geom, 4674));

-- 5
SELECT s.geom, s.nome_munic
FROM sede_munbrasil s
LEFT JOIN pista_pouso_mg p
ON ST_DWithin(s.geom::geography, p.geom::geography, 50000)
WHERE p.id IS NULL AND uf='mg';

-- 6
SELECT r.sigla, c.geom
FROM rodovia_br r
JOIN curso_dagua_mg c
ON c.nome = 'Rio das Velhas' AND ST_Intersects(r.geom, c.geom);

-- 7
SELECT m.nm_mun, r.geom
FROM rodovia_br r
JOIN municipio_mg m
ON ST_Crosses(r.geom, m.geom) AND r.sigla='MG-010';

-- 8
SELECT m.nm_mun
FROM microrregiao_mg mi
JOIN municipio_mg m
ON ST_Contains(mi.geom, m.geom) AND mi.nm_micro='CURVELO';

-- 9
SELECT m.nm_mun
FROM microrregiao_mg mi
JOIN municipio_mg m
ON ST_Touches(mi.geom, m.geom) AND mi.nm_micro='CURVELO';

-- 10
SELECT m.nm_mun, mi.nm_micro, mi.geom
FROM microrregiao_mg mi
JOIN municipio_mg m
ON m.nm_mun IN (
   SELECT m.nm_mun
   FROM microrregiao_mg mi
   JOIN municipio_mg m
   ON ST_Touches(mi.geom, m.geom) AND mi.nm_micro='CURVELO'
)
WHERE ST_Contains(mi.geom, m.geom);

-- 11
SELECT DISTINCT s.nome_munic
FROM sede_munbrasil s
JOIN ferrovia_br f
ON ST_DWithin(ST_Transform(s.geom, 4674)::geography, ST_Transform(f.geom, 4674)::geography, 10000);

-- 12
SELECT s.nome_munic, s.geom
FROM sede_munbrasil s
JOIN sede_munbrasil s2
ON ST_DWithin(ST_Transform(s.geom, 4674)::geography, ST_Transform(s2.geom, 4674)::geography, 200000)
WHERE s2.nome_munic='BELO HORIZONTE';

-- 13
SELECT m.nm_mun, m.geom
FROM municipio_mg m
WHERE ST_DWITHIN(m.geom::geography, (
   SELECT m2.geom
   FROM municipio_mg m2
   WHERE m2.nm_mun='Belo Horizonte'
)::geography, 200000);

-- 14
SELECT SUM(ST_AREA(s.geom::geography)) as area, SUM(s.n_habitant) as total_habitants, m.nm_mun
FROM municipio_mg m
JOIN set_censo_2010_mg s
ON ST_CONTAINS(m.geom, s.geom)
GROUP BY m.nm_mun
HAVING SUM(s.n_habitant) > 100000;

-- 15
SELECT 100 * SUM(ST_AREA(m.geom::geography)) / (
   SELECT SUM(ST_AREA(m2.geom::geography)) as total_area
   FROM mesorregiao_mg m2
)
FROM mesorregiao_mg m
WHERE m.nm_meso IN ('NOROESTE DE MINAS', 'NORTE DE MINAS', 'JEQUITINHONHA');

-- 16
SELECT SUM(ST_NPoints(geom))
FROM limite_mg;

-- 17
SELECT (
   ST_AsText(ST_ENVELOPE(geom))
) as coordinates, (
   ST_ENVELOPE(geom)
) as geom, (
   ST_Distance(ST_PointN(ST_ExteriorRing(geom), 1), ST_PointN(ST_ExteriorRing(geom), 2)::geography)
) as distance_x, (
   ST_Distance(ST_PointN(ST_ExteriorRing(geom), 3), ST_PointN(ST_ExteriorRing(geom), 4)::geography)
) as distance_y
FROM limite_mg;

-- 18
SELECT SUM(s.n_habitant) as total_habitants, SUM(s.n_homens) as total_men, SUM(s.n_mulheres) as total_women, m.nm_mun
FROM set_censo_2010_mg s
JOIN municipio_mg m
ON m.nm_mun = 'Betim' AND ST_Contains(m.geom, s.geom)
GROUP BY m.nm_mun;

-- 19
SELECT SUM(s.n_habitant) as total_habitants, c.comarca
FROM set_censo_2010_mg s
JOIN comarca_tjmg c
ON c.comarca = 'BRUMADINHO' AND ST_Contains(c.geom, s.geom)
GROUP BY c.comarca;

-- 20
SELECT COUNT(m.nm_mun) as num_municipios
FROM municipio_mg m
JOIN bacia_hidrografica_mg b
ON ST_INTERSECTS(ST_Transform(b.geom, 4674), ST_Transform(m.geom, 4674))
WHERE b.nome='Bacia do Rio Doce';

-- 21
SELECT COUNT(id) as num_barragens, nome_munic
FROM barragem_rejeito
GROUP BY nome_munic;

-- 22
SELECT avg(ST_Distance(l.geom, s.geom)) as average_distance, s.nome_munic
FROM localidade_ibge l
JOIN sede_munbrasil s
ON s.nome_munic = UPPER(m.nm_mun)
GROUP BY s.nome_munic;

-- 23
SELECT d.ddd, ST_UNION(mu.geom) as geom
FROM ddd_munic d
JOIN munbrasilpib m
ON d.codibge = m.cod AND m.nommuni = mu.nm_mun
GROUP BY d.ddd;

-- 24
SELECT c.comarca, c.geom
FROM comarca_tjmg c
JOIN macrorregiao_mg m
ON ST_INTERSECTS(c.geom, m.geom) AND m.macroreg='Jequitinhonha';

-- 25
SELECT b.*
FROM barragem_rejeito b
JOIN area_protecao_especial_mg a
ON ST_CONTAINS(ST_Transform(a.geom, 4674), ST_Transform(b.geom, 4674));

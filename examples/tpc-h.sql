-- Snowflake Sample Data (TPCH Schema)

-- Nation Table
CREATE TABLE nation (
    n_nationkey INTEGER PRIMARY KEY,
    n_name VARCHAR(25),
    n_regionkey INTEGER,
    n_comment VARCHAR(152)
);

INSERT INTO nation VALUES
    (0, 'ALGERIA', 0, 'haggle. carefully final deposits detect slyly agai'),
    (1, 'ARGENTINA', 1, 'al foxes promise slyly according to the regular accounts. bold requests alon'),
    (2, 'BRAZIL', 1, 'y alongside of the pending deposits. carefully special packages are about the ironic forges. slyly special'),
    (3, 'CANADA', 1, 'eas hang ironic, silent packages. slyly regular packages are furiously over the tithes. fluffily bold'),
    (4, 'EGYPT', 4, 'y above the carefully unusual theodolites. final dugouts are quickly across the furiously regular d'),
    (5, 'ETHIOPIA', 0, 'ven packages wake quickly. regu'),
    (6, 'FRANCE', 3, 'refully final requests. regular, ironi'),
    (7, 'GERMANY', 3, 'l platelets. regular accounts x-ray: unusual, regular acco'),
    (8, 'INDIA', 2, 'ss excuses cajole slyly across the packages. deposits print aroun'),
    (9, 'INDONESIA', 2, 'slyly express asymptotes. regular deposits haggle slyly. carefully ironic hockey players sleep blithely. carefull'),
    (10, 'IRAN', 4, 'efully alongside of the slyly final dependencies.'),
    (11, 'IRAQ', 4, 'nic deposits boost atop the quickly final requests? quickly regula'),
    (12, 'JAPAN', 2, 'ously. final, express gifts cajole a'),
    (13, 'JORDAN', 4, 'ic deposits are blithely about the carefully regular pa'),
    (14, 'KENYA', 0, 'pending excuses haggle furiously deposits. pending, express pinto beans wake fluffily past t'),
    (15, 'MOROCCO', 0, 'rns. blithely bold courts among the closely regular packages use furiously bold platelets?'),
    (16, 'MOZAMBIQUE', 0, 's. ironic, unusual asymptotes wake blithely r'),
    (17, 'PERU', 1, 'platelets. blithely pending dependencies use fluffily across the even pinto beans. carefully silent accoun'),
    (18, 'CHINA', 2, 'c dependencies. furiously express notornis sleep slyly regular accounts. ideas sleep. depos'),
    (19, 'ROMANIA', 3, 'ular asymptotes are about the furious multipliers. express dependencies nag above the ironically ironic account'),
    (20, 'SAUDI ARABIA', 4, 'ts. silent requests haggle. closely express packages sleep across the blithely'),
    (21, 'VIETNAM', 2, 'hely enticingly express accounts. even, final'),
    (22, 'RUSSIA', 3, 'requests against the platelets use never according to the quickly regular pint'),
    (23, 'UNITED KINGDOM', 3, 'eans boost carefully special requests. accounts are. carefull'),
    (24, 'UNITED STATES', 1, 'y final packages. slow foxes cajole quickly. quickly silent platelets breach ironic accounts. unusual pinto be');

-- Region Table
CREATE TABLE region (
    r_regionkey INTEGER PRIMARY KEY,
    r_name VARCHAR(25),
    r_comment VARCHAR(152)
);

INSERT INTO region VALUES
    (0, 'AFRICA', 'lar deposits. blithely final packages cajole. regular waters are final requests. regular accounts are according to'),
    (1, 'AMERICA', 'hs use ironic, even requests. s'),
    (2, 'ASIA', 'ges. thinly even pinto beans ca'),
    (3, 'EUROPE', 'ly final courts cajole furiously final excuse'),
    (4, 'MIDDLE EAST', 'uickly special accounts cajole carefully blithely close requests. carefully final asymptotes haggle furiousl');

-- Customer Table
CREATE TABLE customer (
    c_custkey INTEGER PRIMARY KEY,
    c_name VARCHAR(25),
    c_address VARCHAR(40),
    c_nationkey INTEGER,
    c_phone VARCHAR(15),
    c_acctbal DECIMAL(15,2),
    c_mktsegment VARCHAR(10),
    c_comment VARCHAR(117)
);

INSERT INTO customer VALUES
    (1, 'Customer#000000001', 'IVhzIApeRb ot,c,E', 15, '25-989-741-2988', 711.56, 'BUILDING', 'to the even, regular platelets. regular, ironic epitaphs nag e'),
    (2, 'Customer#000000002', 'XSTf4,NCwDVaWNe6tEgvwfmRchLXak', 13, '23-768-687-3665', 121.65, 'AUTOMOBILE', 'l accounts. blithely ironic theodolites integrate boldly: caref'),
    (3, 'Customer#000000003', 'MG9kdTD2WBHm', 1, '11-719-748-3364', 7498.12, 'AUTOMOBILE', ' deposits eat slyly ironic, even instructions. express foxes detect slyly. blithely even accounts abov'),
    (4, 'Customer#000000004', 'XxVSJsLAGtn', 4, '14-128-190-5944', 2866.83, 'MACHINERY', ' requests. final, regular ideas sleep final accou'),
    (5, 'Customer#000000005', 'KvpyuHCplrB84WgAiGV6sYpZq7Tj', 3, '13-750-942-6364', 794.47, 'HOUSEHOLD', 'n accounts will have to unwind. foxes cajole accor'),
    (6, 'Customer#000000006', 'sKZz0CsnMD7mp4Xd0YrBvx,LREYKUWAh yVn', 20, '30-114-968-4951', 7638.57, 'AUTOMOBILE', 'tions. even deposits boost according to the slyly bold packages. final accounts cajole requests. furious'),
    (7, 'Customer#000000007', 'TcGe5gaZNgVePxU5kRrvXBfkasDTea', 18, '28-190-982-9759', 9561.95, 'AUTOMOBILE', 'ainst the ironic, express theodolites. express, even pinto beans among the exp'),
    (8, 'Customer#000000008', 'I0B10bB0AymmC, 0PrRYBCP1yGJ8xcBPmWhl5', 17, '27-147-574-9335', 6819.74, 'BUILDING', 'among the slyly regular theodolites kindle blithely courts. carefully even theodolites haggle slyly along the ide'),
    (9, 'Customer#000000009', 'xKiAFTjUsCuxfeleNqefumTrjS', 8, '18-338-906-3675', 8324.07, 'FURNITURE', 'r theodolites according to the requests wake thinly excuses: pending requests haggle furiousl'),
    (10, 'Customer#000000010', '6LrEaV6KR6PLVcgl2ArL Q3rqzLzcT1 v2', 5, '15-741-346-9870', 2753.54, 'HOUSEHOLD', 'es regular deposits haggle. fur');

-- Supplier Table
CREATE TABLE supplier (
    s_suppkey INTEGER PRIMARY KEY,
    s_name VARCHAR(25),
    s_address VARCHAR(40),
    s_nationkey INTEGER,
    s_phone VARCHAR(15),
    s_acctbal DECIMAL(15,2),
    s_comment VARCHAR(101)
);

INSERT INTO supplier VALUES
    (1, 'Supplier#000000001', ' N kD4on9OM Ipw3,gf0JBoQDd7tgrzrddZ', 17, '27-918-335-1736', 5755.94, 'each slyly above the careful'),
    (2, 'Supplier#000000002', '89eJ5ksX3ImxJQBvxObC,', 5, '15-679-861-2259', 4032.68, ' slyly bold instructions. idle dependen'),
    (3, 'Supplier#000000003', 'q1,G3Pj6OjIuUYfUoH18BFTKP5aU9bEV3', 1, '11-383-516-1199', 4192.40, 'blithely silent requests after the express dependencies are sl'),
    (4, 'Supplier#000000004', 'Bk7ah4CK8SYQTepEmvMkkgMwg', 15, '25-843-787-7479', 4641.08, 'riously even requests above the exp'),
    (5, 'Supplier#000000005', 'Gcdm2rJRzl5qlTVzc', 11, '21-151-690-3663', -283.84, '. slyly regular pinto bea');

-- Part Table
CREATE TABLE part (
    p_partkey INTEGER PRIMARY KEY,
    p_name VARCHAR(55),
    p_mfgr VARCHAR(25),
    p_brand VARCHAR(10),
    p_type VARCHAR(25),
    p_size INTEGER,
    p_container VARCHAR(10),
    p_retailprice DECIMAL(15,2),
    p_comment VARCHAR(23)
);

INSERT INTO part VALUES
    (1, 'goldenrod lavender spring chocolate lace', 'Manufacturer#1', 'Brand#13', 'PROMO BURNISHED COPPER', 7, 'JUMBO PKG', 901.00, 'ly. slyly ironi'),
    (2, 'blush thistle blue yellow saddle', 'Manufacturer#1', 'Brand#13', 'LARGE BRUSHED BRASS', 1, 'LG CASE', 902.00, 'lar accounts amo'),
    (3, 'spring green yellow purple cornsilk', 'Manufacturer#4', 'Brand#42', 'STANDARD POLISHED BRASS', 21, 'WRAP CASE', 903.00, 'egular deposits hag'),
    (4, 'cornflower chocolate smoke green pink', 'Manufacturer#3', 'Brand#34', 'SMALL PLATED BRASS', 14, 'MED DRUM', 904.00, 'p furiously r'),
    (5, 'forest brown coral puff cream', 'Manufacturer#3', 'Brand#32', 'STANDARD POLISHED TIN', 15, 'SM PKG', 905.00, 'wake carefully');

-- Orders Table
CREATE TABLE orders (
    o_orderkey INTEGER PRIMARY KEY,
    o_custkey INTEGER,
    o_orderstatus VARCHAR(1),
    o_totalprice DECIMAL(15,2),
    o_orderdate DATE,
    o_orderpriority VARCHAR(15),
    o_clerk VARCHAR(15),
    o_shippriority INTEGER,
    o_comment VARCHAR(79)
);

INSERT INTO orders VALUES
    (1, 1, 'O', 173665.47, '1996-01-02', '5-LOW', 'Clerk#000000951', 0, 'nstructions sleep furiously among'),
    (2, 2, 'O', 46929.18, '1996-12-01', '1-URGENT', 'Clerk#000000880', 0, ' foxes. pending accounts at the pending, silent asymptot'),
    (3, 3, 'F', 193846.25, '1993-10-14', '5-LOW', 'Clerk#000000955', 0, 'sly final accounts boost. carefully regular ideas cajole carefully. depos'),
    (4, 4, 'O', 32151.78, '1995-10-11', '5-LOW', 'Clerk#000000124', 0, 'sits. slyly regular warthogs cajole. regular, regular theodolites acro'),
    (5, 5, 'F', 144659.20, '1994-07-30', '5-LOW', 'Clerk#000000925', 0, 'quickly. bold deposits sleep slyly. packages use slyly'),
    (6, 6, 'F', 58749.59, '1992-02-21', '4-NOT SPECIFIED', 'Clerk#000000058', 0, 'ggle. special, final requests are against the furiously specia'),
    (7, 7, 'O', 252004.18, '1996-01-10', '2-HIGH', 'Clerk#000000470', 0, 'ly special requests'),
    (32, 1, 'O', 208660.75, '1995-07-16', '2-HIGH', 'Clerk#000000616', 0, 'ise blithely bold, regular requests. quickly unusual dep'),
    (33, 10, 'F', 163243.98, '1993-10-27', '3-MEDIUM', 'Clerk#000000409', 0, 'uriously. furiously final request'),
    (34, 6, 'O', 58949.67, '1998-07-21', '3-MEDIUM', 'Clerk#000000223', 0, 'ly final packages. fluffily final deposits wake blithely ideas. spe');

-- PartSupp Table (Supplier-Part relationship)
CREATE TABLE partsupp (
    ps_partkey INTEGER,
    ps_suppkey INTEGER,
    ps_availqty INTEGER,
    ps_supplycost DECIMAL(15,2),
    ps_comment VARCHAR(199),
    PRIMARY KEY (ps_partkey, ps_suppkey)
);

INSERT INTO partsupp VALUES
    (1, 1, 3325, 771.64, 'final theodolites'),
    (1, 2, 8076, 993.49, 'ven ideas. quickly even packages print. pending multipliers must have to are fluff'),
    (2, 1, 3956, 337.09, 'after the fluffily ironic deposits? slyl'),
    (2, 2, 8895, 378.49, 'nal accounts are quickly carefully final requests. furiously even requests are quickly. fluffily ironic deposits'),
    (3, 1, 4651, 357.84, 'nal instructions wake carefully. blithely express accounts nag furiously. carefully regular instructions'),
    (3, 2, 4093, 306.39, 'blithely regular requests are. furiously even deposits wake blithely bold sentiments. regular requests haggle'),
    (4, 1, 8713, 86.99, 'requests. final accounts cajole carefully. even, express requests sleep'),
    (4, 2, 2096, 88.58, 'ously regular deposits haggle blithely carefully even theodolites. final deposits haggle blithely'),
    (5, 1, 1339, 50.52, 'carefully bold requests. ironic, bold asymptotes wake blithely regular requests. final, regular deposits'),
    (5, 2, 7735, 50.52, 'carefully bold requests. ironic, bold asymptotes wake blithely regular requests. final, regular deposits');

-- LineItem Table
CREATE TABLE lineitem (
    l_orderkey INTEGER,
    l_partkey INTEGER,
    l_suppkey INTEGER,
    l_linenumber INTEGER,
    l_quantity DECIMAL(15,2),
    l_extendedprice DECIMAL(15,2),
    l_discount DECIMAL(15,2),
    l_tax DECIMAL(15,2),
    l_returnflag VARCHAR(1),
    l_linestatus VARCHAR(1),
    l_shipdate DATE,
    l_commitdate DATE,
    l_receiptdate DATE,
    l_shipinstruct VARCHAR(25),
    l_shipmode VARCHAR(10),
    l_comment VARCHAR(44),
    PRIMARY KEY (l_orderkey, l_linenumber)
);

INSERT INTO lineitem VALUES
    (1, 1, 1, 1, 17.00, 21168.23, 0.04, 0.02, 'N', 'O', '1996-03-13', '1996-02-12', '1996-03-22', 'DELIVER IN PERSON', 'TRUCK', 'egular courts above the'),
    (1, 2, 2, 2, 36.00, 45983.16, 0.09, 0.06, 'N', 'O', '1996-04-12', '1996-02-28', '1996-04-20', 'TAKE BACK RETURN', 'MAIL', 'ly final dependencies: slyly bold'),
    (2, 3, 3, 1, 38.00, 44694.46, 0.00, 0.05, 'N', 'O', '1997-01-28', '1997-01-14', '1997-02-02', 'TAKE BACK RETURN', 'RAIL', 'ven requests. deposits breach a'),
    (3, 4, 4, 1, 45.00, 54058.05, 0.06, 0.00, 'R', 'F', '1994-02-02', '1994-01-04', '1994-02-23', 'NONE', 'AIR', 'ongside of the furiously brave acco'),
    (3, 1, 1, 2, 49.00, 46796.47, 0.10, 0.00, 'R', 'F', '1993-11-09', '1993-12-20', '1993-11-24', 'TAKE BACK RETURN', 'RAIL', ' unusual accounts. eve'),
    (4, 5, 5, 1, 30.00, 30690.90, 0.03, 0.08, 'N', 'O', '1996-01-10', '1995-12-14', '1996-01-18', 'DELIVER IN PERSON', 'REG AIR', '- quickly regular packages sleep. idly'),
    (5, 1, 1, 1, 15.00, 17554.25, 0.02, 0.04, 'R', 'F', '1994-10-31', '1994-08-31', '1994-11-20', 'NONE', 'AIR', 'ts wake furiously'),
    (5, 2, 2, 2, 26.00, 23946.04, 0.07, 0.02, 'R', 'F', '1994-10-16', '1994-09-25', '1994-10-19', 'NONE', 'FOB', 'sts use slyly quickly special instruc'),
    (5, 3, 3, 3, 50.00, 64436.00, 0.08, 0.03, 'A', 'F', '1994-08-08', '1994-10-13', '1994-08-26', 'DELIVER IN PERSON', 'AIR', 'eodolites. fluffily unusual'),
    (32, 1, 1, 1, 28.00, 28955.12, 0.05, 0.08, 'N', 'O', '1995-10-23', '1995-08-27', '1995-10-26', 'TAKE BACK RETURN', 'TRUCK', 'sleep quickly. req');

-- Display summary
SELECT 'Database setup complete!' AS status;
SELECT 'Tables created:' AS info;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'main' ORDER BY table_name;

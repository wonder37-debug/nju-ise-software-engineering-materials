USE mycap;

#查询仓库位于Dallas且库存数量低于200000的商品的编号、名称和库存数量；结果按照库存数量从小到大排序。
SELECT pid,pname,quantity FROM products WHERE city='Dallas' AND  quantity<200000 ORDER BY quantity;

#查询满足以下条件的订单的编号和销售金额：Dallas的顾客通过位于Duluth的供应商购买商品；结果按照订单编号从大到小排序。
SELECT orders.ordno,orders.dollars FROM orders,customers,agents WHERE orders.cid=customers.cid AND orders.aid=agents.aid AND customers.city='Dallas' AND agents.city='Duluth' ORDER BY orders.ordno DESC;

#查询满足以下条件的顾客的编号和姓名：没有购买过任何商品；结果按照顾客姓名从小到大排序。
SELECT customers.cid,customers.cname FROM customers WHERE NOT EXISTS(SELECT * FROM orders WHERE orders.cid=customers.cid) ORDER BY customers.cname;

#查询满足以下条件的供应商编号a和商品编号p：编号为a的供应商只销售过编号为p的这一种商品；结果按照供应商编号从小到大排序
SELECT aid a,MAX(pid) p FROM orders GROUP BY aid HAVING COUNT(DISTINCT pid)=1 ORDER BY aid;

#查询每一个供应商的所有订单销售金额的最高值，结果返回供应商的编号及其订单金额的最高值；结果按照供应商编号从小到大排序。（不考虑没有销售订单的供应商；请分别写出：不使用统计函数、使用统计函数（使用或不使用group by子句）等三种不同表示方法及其返回的查询结果））
SELECT DISTINCT o1.aid,o1.dollars FROM orders o1 WHERE NOT EXISTS(SELECT * FROM orders o2 WHERE o2.aid=o1.aid AND o2.dollars>o1.dollars) ORDER BY o1.aid;
SELECT orders.aid,MAX(orders.dollars) FROM orders GROUP BY orders.aid ORDER BY orders.aid;
SELECT DISTINCT o1.aid,(SELECT MAX(o2.dollars) from orders o2 WHERE o2.aid=o1.aid) FROM orders o1 ORDER BY o1.aid;

#查询满足下述条件的供应商：该供应商每一份订单的销售金额都超过500元；结果返回供应商的编号及其所有订单的累计销售金额，并按照下述要求进行排序：先按照累计销售金额从大到小排序，在累计销售金额相同时再按照供应商的编号从小到大排序。（不考虑没有销售订单的供应商；请写出使用HAVING子句和不使用HAVING子句的两种不同表示方法）
SELECT orders.aid,SUM(orders.dollars) FROM orders GROUP BY orders.aid HAVING MIN(dollars)>500 ORDER BY SUM(dollars)DESC ,aid;
SELECT aid,sum(dollars) FROM orders o1 WHERE NOT EXISTS(SELECT * FROM orders o2 WHERE o2.aid=o1.aid AND o2.dollars<500) GROUP BY aid ORDER BY sum(dollars) DESC,aid;

#查询满足以下条件的顾客的编号：通过所有供应商都购买过商品；结果按照顾客编号从小到大排序。
SELECT orders.cid FROM orders GROUP BY orders.cid HAVING COUNT(DISTINCT aid)=(SELECT COUNT(*) FROM agents) ORDER BY orders.cid;

#查询满足以下条件的商品的编号：单价不小于1，并且所有位于Duluth市的顾客都购买过；结果按照商品编号从小到大排序。
SELECT orders.pid FROM customers,orders,products WHERE products.pid=orders.pid AND customers.cid=orders.cid AND customers.city='Duluth' AND products.price>=1 GROUP BY orders.pid HAVING COUNT(DISTINCT orders.cid)=(SELECT COUNT(*) FROM customers WHERE city='Duluth') ORDER BY orders.pid;

#查询每一位顾客的最后一份订单，结果返回顾客编号，最后一份订单的订单编号、订购年份、订购月份、距离当前的时间差（天数）。结果按照距离当前的天数从大到小排序。（以订单编号的大小区分订单的先后，编号大的订单在后；不考虑没有订单的顾客；请使用系统内置的日期函数）
SELECT cid, ordno, YEAR(orddate) AS ord_year, MONTH(orddate) AS ord_month, DATEDIFF('2026.04.06', orddate) AS diff_days FROM orders WHERE ordno IN (SELECT MAX(ordno) FROM orders GROUP BY cid) ORDER BY diff_days DESC;

#查询满足以下条件的商品编号pid、供应商编号aid、顾客所在城市city：位于同一个城市city中的所有顾客，都通过供应商aid去购买过商品pid；结果依次按照商品编号、供应商编号、顾客所在城市从小到大排序。
SELECT o.pid,o.aid,c.city FROM orders o JOIN customers c ON o.cid=c.cid GROUP BY o.pid,o.aid,c.city HAVING COUNT(DISTINCT o.cid)=(SELECT COUNT(*) FROM customers WHERE city=c.city) ORDER BY o.pid,o.aid,c.city;
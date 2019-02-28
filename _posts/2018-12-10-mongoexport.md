1. mongoexport -h 172.31.124.16 --port 27017 -u root -p Hanergyrj001 -d Solarfac -c ancillary_info_irradiation -f deviceID,irradiation,sendTime --type=csv -o irradiation.csv --authenticationDatabase=admin

原

# MongoDB----时间查询---时间为String时的统计查询

2017年04月14日 11:39:31 [张小凡vip](https://me.csdn.net/q383965374) 阅读数：11825

 版权声明：本文为博主原创文章，未经博主允许不得转载。	https://blog.csdn.net/q383965374/article/details/70170523

MongoDB有自己的时间类型ISODate。如果使用ISODate的话在MongoDB中就能很方便的进行时间的统计。

格式如下

db.products.find({"date": {"$gte": new ISODate("2017-04-12 08:14:15.656")}});

但是有时候MongoDB的时间字段不小心存储成了String类型。

在Mysql中可以使用TO_Day很方便的把String类型的字段转换为时间再统计，但是MongoDB不支持。

因为MongoDB有自己的时间类型，且目前它只认可自己的时间类型。

所以如果在MongoDB中把时间存储成了字符串，需要统计时只能使用聚类来统计，聚类可以在统计时修改原字段的类型为Date。

db.myObject.aggregate(
{$project :{"dateTime": {"$gte": new ISODate($date)}}},

{

​                        $match:{"$gt":{"$dateTime":new ISODate("2017-04-12 08:14:15.656")}}       

​                    }

{$group:{_id:"$id","count":{$sum:1}}}

);

import org.apache.spark.sql.{Column, DataFrame, SparkSession}
import org.apache.spark.sql.expressions.Window
import org.apache.spark.sql.functions._
implicit val spark = SparkSession
  .builder()
  .master("local[1]")
  .config(
    "spark.serializer",
    "org.apache.spark.serializer.KryoSerializer"
  )
  .appName("sampleCodeForReference")
  .getOrCreate()

import spark.implicits._

case class RevenueModel(product: String, category: String, revenue: Int)

val dataset = Seq(
  ("Thin", "cell phone", 6000),
  ("Normal", "tablet", 1500),
  ("Mini", "tablet", 5500),
  ("Ultra thin", "cell phone", 5000),
  ("Very thin", "cell phone", 6000),
  ("Big", "tablet", 2500),
  ("Bendable", "cell phone", 3000),
  ("Foldable", "cell phone", 3000),
  ("Pro", "tablet", 4500),
  ("Pro2", "tablet", 6500))
  .toDF("product", "category", "revenue").as[RevenueModel]

//    best-selling and the second best-selling products in every category
val byCat = Window.partitionBy('category).orderBy('revenue desc)
val rankByCat = dense_rank() over byCat
// dataset.withColumn("rank", rankByCat).filter('rank === 1).show()
// dataset.withColumn("rank", rankByCat).filter('rank === 2).show()

val singleoutput = dataset.filter($"category" === "tablet").collect().foldLeft[Int](0)(
  (maxrn, revmod) => if ( revmod.revenue>maxrn) revmod.revenue else maxrn
)
print(singleoutput)

val test = dataset.groupByKey(row => (row.category))
val test2 = test.flatMapGroups((key: String, revenues: Iterator[RevenueModel])=>
  {
    // Access to the Iterator needs to be restrictive
    val revseq = revenues.toSeq
    val head = revseq.head
    val start = Seq((key, head.product, head.revenue))
    println("head")
    println(head)
    println("tail")
    val tail = revseq.tail
    val groupop = tail.foldLeft(start)(
     (maxrn, revmod) => {
      println(revmod)
       // If the next row revenue is more then only add that row
      if (revmod.revenue >= maxrn.last._3) maxrn ++ Seq((key, revmod.product, revmod.revenue))
      else maxrn
      // maxrn ++ Seq((revmod.category, revmod.product, revmod.revenue))
    }
)
    println(groupop)
    groupop
  }
)

test2.show(false)
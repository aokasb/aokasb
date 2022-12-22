import gov.cms.qpp.egworkbooks.inputs.WorkbooksParser
import gov.cms.qpp.egworkbooks.inputs.models.{ChronicEpisodeList, SubpopTier1}
import org.apache.spark.sql.SparkSession
implicit val version = "2022"
implicit val workbookLookup = WorkbooksParser.getFullWorkbookNames(version)


// implicit val spark: SparkSession = SparkSession
//  .builder()
//  .config("spark.master", "local")
//  .getOrCreate()

implicit val spark = SparkSession
  .builder()
  .master("local[2]")
  .config(
    "spark.serializer",
    "org.apache.spark.serializer.KryoSerializer"
  )
  .appName("sampleCodeForReference")
  .getOrCreate()

import spark.implicits._
import scala.reflect.runtime.universe._
// WorkbooksParser.meta.get(typeOf[ChronicEpisodeList])
//print(WorkbooksParser.meta)
//print(WorkbooksParser.meta.contains(typeOf[SubpopTier1]))
val df = WorkbooksParser.parseWorkbooks("2022", false)
df.chronicMedicalCodesWorkbook.chronicEmCodes.show(5)
import gov.cms.qpp.egworkbooks.outputs.ChronicWorkbook
val chronicWorkbook = ChronicWorkbook.get(df.chronicMedicalCodesWorkbook)(spark)
chronicWorkbook.chronicEmCodes.show(4, false)
import gov.cms.qpp.sparkutils.Implicits._
import gov.cms.qpp.egworkbooks.outputs.models.ChronicEmCodes
val outputChronicEmCodes =
  df.chronicMedicalCodesWorkbook.chronicEmCodes
    .selectColumnsFor[ChronicEmCodes]





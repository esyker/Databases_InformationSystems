<html>
	<body>
	<a href="insert_client_info.php">Home</a>
		<form action="insert_dental_charting.php" method="post">
			<h3>New Dental Charting</h3>
<?php
	$host = "db.tecnico.ulisboa.pt";
	$user = "ist186980";
	$pass = "tcsa6810";
	$dsn = "mysql:host=$host;dbname=$user";
	try
	{
		$connection = new PDO($dsn, $user, $pass);
	}
	catch(PDOException $exception)
	{
		echo("<p>Error: ");
		echo($exception->getMessage());
		echo("</p>");
		exit();
	}
	
	$VAT_doctor = $_GET['VAT_doctor'];
	$date_timestamp = $_GET['date_timestamp'];
	echo("<input type=\"hidden\" name=\"VAT_doctor\" value=\"$VAT_doctor\">");
	echo("<input type=\"hidden\" name=\"date_timestamp\" value=\"$date_timestamp\">");
	
	
	echo("<p>Procedure name: <input type=\"text\" name=\"procedure_name\"/></p>");
	echo("<p>Procedure type: <input type=\"text\" name=\"procedure_type\"/></p>");
	echo("<p>Procedure description: <input type=\"text\" name=\"prodedure_description\"/></p>");
	
	$sql = $connection->prepare("SELECT * from teeth");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p>No teeth found in the database</p>");
		$connection = null;
		exit();
	}
	
	echo("<table border=\"0\" cellspacing=\"5\">\n");
	echo("<tr>\n<td>Tooth</td>\n<td>Measure (mm)</td>\n<td>Description<td>\n</tr>\n");
	foreach($result as $row)
	{
		echo("<tr>\n");	
		echo("<td><input type=\"checkbox\" name=\"teeth[]\" value=\"{$row['quadrant']}|{$row['number_']}\" >{$row['name']} (quadrant {$row['quadrant']}, number {$row['number_']})</td>\n");
		echo("<td><input type=\"text\" name=\"measure_tooth[{$row['quadrant']}|{$row['number_']}]\"/></td>\n");
		echo("<td><input type=\"text\" name=\"description_tooth[{$row['quadrant']}|{$row['number_']}]\"/></td>\n");
		echo("</tr>\n");
		
	}
	echo("</table>");
	echo("<p><input type=\"submit\" value=\"Create\"/></p>");
	
	$connection = null;
?>
		</form>
	</body>
</html>
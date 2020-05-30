<html>
	<body>
	<a href="insert_client_info.php">Home</a>
		<form action="insert_consultation.php" method="post">
			<h3>New Consultation</h3>
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
	if($VAT_doctor == '' || $VAT_doctor == NULL)
	{
		echo("<p>Error: VAT_doctor must not be empty</p>");
		exit();
	}
	if($date_timestamp == '' || $date_timestamp == NULL)
	{
		echo("<p>Error: date_timestamp must not be empty</p>");
		exit();
	}
	echo("<input type=\"hidden\" name=\"VAT_doctor\" value=\"$VAT_doctor\">");
	echo("<input type=\"hidden\" name=\"date_timestamp\" value=\"$date_timestamp\">");
	
	$sql = $connection->prepare("SELECT * from appointment WHERE VAT_doctor = :VAT_doctor AND date_timestamp = :date_timestamp");
	$sql->bindValue(':VAT_doctor', "$VAT_doctor");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p>Error: There is no appointment with the parameters specified</p>");
		$connection = null;
		exit();
	}
	
	
	echo("<p>Subjective observation: <input type=\"text\" name=\"SOAP_S\"/></p>");
	echo("<p>Objective observation: <input type=\"text\" name=\"SOAP_O\"/></p>");
	echo("<p>Assessment: <input type=\"text\" name=\"SOAP_A\"/></p>");
	echo("<p>Plan: <input type=\"text\" name=\"SOAP_P\"/></p>");
	
	echo("<p>Assistant nurses:</p>");
	$sql = $connection->prepare("SELECT * from nurse NATURAL JOIN employee");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p>Error: There are no nurses in the database</p>");
	}
	else
	{
		
		foreach($result as $row)
		{
			echo("<p><input type=\"checkbox\" name=\"VATs_nurses[]\" value=\"{$row['VAT']}\">{$row['name']} (VAT: {$row['VAT']})</p>");
		}
	}
	
	
	echo("<p>Diagnostics:</p>");
	$sql = $connection->prepare("SELECT * from diagnostic_code");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p>Error: There are no diagnostic codes in the database</p>");
	}
	else
	{
		foreach($result as $row)
		{
			echo("<p><input type=\"checkbox\" name=\"diagnostic_codes[]\" value=\"{$row['ID']}\">{$row['description']} (ID: {$row['ID']})</p>");
		}
	}
	
	
	echo("<p>Prescriptions:</p>");
	$sql2 = $connection->prepare("SELECT * from medication");
	$sql2->execute();
	$result2 = $sql2->fetchAll(PDO::FETCH_ASSOC);
	if(count($result2) == 0)
	{
		echo("<p>Error: There are no medications in the database</p>");
	}
	else
	{
		echo("<table border=\"0\" cellspacing=\"5\">\n");
		foreach($result2 as $row)
		{
			echo("<tr>\n");	
			echo("<td><input type=\"checkbox\" name=\"prescription_medication[]\" value=\"{$row['name']}|{$row['lab']}\" >{$row['name']} (Lab: {$row['lab']}) </td>\n");
			echo("<td>Dosage: <input type=\"text\" name=\"prescription_dosage[{$row['name']}|{$row['lab']}]\"> </td>\n");
			echo("<td>Description: <input type=\"text\" name=\"prescription_description[{$row['name']}|{$row['lab']}]\"> </td>\n");
			echo("<td>Diagnostic: <select name=\"prescription_diagnostic[{$row['name']}|{$row['lab']}]\">");
			$sql->execute();
			$result = $sql->fetchAll(PDO::FETCH_ASSOC);
			foreach($result as $row2)
			{
				echo("<option value=\"{$row2['ID']}\">{$row2['description']} (ID: {$row2['ID']})</option>");
			}
			echo("</select>");
			echo("</td>\n");
			echo("</tr>\n");
		}
		
		echo("</table>");
		echo("<p><input type=\"submit\" value=\"Create\"/></p>");
	}
	
	$connection = null;
?>
		</form>
	</body>
</html>
<html>
	<body>
	<a href="insert_client_info.php">Home</a>
	<h3>Clients</h3>
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
	
	$VAT = $_REQUEST['VAT'];
	$name = $_REQUEST['name'];
	$street = $_REQUEST['street'];
	$city = $_REQUEST['city'];
	$zip = $_REQUEST['zip'];

	$sql = $connection->prepare("SELECT * FROM client WHERE VAT LIKE :VAT AND (name LIKE :name AND street LIKE :street AND city LIKE :city AND zip LIKE :zip)");
	$sql->bindValue(':VAT', "%{$VAT}%");
	$sql->bindValue(':name', "%{$name}%");
	$sql->bindValue(':street', "%{$street}%");
	$sql->bindValue(':city', "%{$city}%");
	$sql->bindValue(':zip', "%{$zip}%");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);

	
	if(count($result) == 0)
	{
		echo("<p>No clients found</p>");
		echo("<p><a href=\"create_new_client.php\">New Client</a></p>");
		$connection = null;
		exit();
	}

	echo("<table border=\"0\" cellspacing=\"5\">\n");
	echo("<tr>\n<td>VAT</td>\n<td>Name</td>\n<td>Street</td>\n<td>City</td>\n<td>Zip</td>\n</tr>");
	foreach($result as $row)
	{
		echo("<tr>\n");
		echo("<td><a href=\"appointments_list.php?VAT=");
		echo($row['VAT']);
		echo("\">{$row['VAT']}</a></td>\n");
		echo("<td>{$row['name']}</td>\n");
		echo("<td>{$row['street']}</td>\n");
		echo("<td>{$row['city']}</td>\n");
		echo("<td>{$row['zip']}</td>\n");
		echo("<td><a href=\"schedule_appointment.php?VAT=");
		echo($row['VAT']);
		echo("\">Schedule appointment</a></td>\n");
		echo("</tr>\n");
	}
	echo("</table>\n");
	echo("<p><a href=\"create_new_client.php\">New Client</a></p>");
	
	$connection = null;
?>
	</body>
</html>
/* 
Citation for the following code:
Date: 11/4/2025 (various additional dates)
Base code used from Exploration - Web Application Technology and Exploration Implementing CUD Operations in your app
URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-web-application-technology-2?module_item_id=25645131
URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25645149
*/


// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

const PORT = 11000;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        res.render('home'); // Render the home.hbs file
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});

app.get('/food', async function (req, res) {
    try {
        // Create and execute our queries
        const query1 = `SELECT Food.idFood, Food.foodName, Food.quantity, Food.unit FROM Food;`;
        const [Food] = await db.query(query1);


        // Render the food.hbs file, and also send the renderer
        //  an object that contains food information
        res.render('food', { food: Food });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/Animals', async function (req, res) {
    try {
        // Create and execute our queries
        const query1 = `SELECT Animals.idAnimal, Animals.name, Animals.type, Animals.dateOfBirth, Food.foodName AS 'Diet' FROM Animals \
        LEFT JOIN Food ON Animals.idFood = Food.idFood;`;
        const query2 = 'SELECT * FROM Food;';
        const [Animals] = await db.query(query1);
        const [Diet] = await db.query(query2);

        // Prompted Claude AI to give code on how to format the dates shorthand:
        Animals.forEach(animal => {
            if (animal.dateOfBirth) {
                const date = new Date(animal.dateOfBirth);
                animal.dateOfBirth = date.toLocaleDateString('en-US', { 
                    year: 'numeric', 
                    month: 'short', 
                    day: 'numeric' 
                });
            }
        });        

        // Render the animals.hbs file, and also send the renderer
        //  an object that contains animals information
        res.render('animals', { animals: Animals, food: Diet });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


app.get('/passes', async function (req, res) {
    try {
        // Create and execute our queries
        const query1 = `SELECT idPass, price, category FROM Passes;`;
        const [passes] = await db.query(query1);


        // Render the passes.hbs file, and also send the renderer
        //  an object that contains pass information
        res.render('passes', { passes: passes });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/sales', async function (req, res) {
    try {
        // Query 1: all sales
    const [sales] = await db.query(`
    SELECT 
        Sales.idSale,
        Passes.category AS passCategory,
        CONCAT(Employees.firstName, ' ', Employees.lastName) AS employeeName,
        Sales.passesSold,
        Sales.saleDate
    FROM Sales 
    JOIN Passes ON Sales.idPass = Passes.idPass
    JOIN Employees ON Sales.idEmployee = Employees.idEmployee
`);


        // Query 2: all passes for dropdown
        const [passes] = await db.query(`
            SELECT idPass, category
            FROM Passes;
        `);

        // Query 3: all employees for dropdown
        const [employees] = await db.query(`
            SELECT idEmployee, firstName, lastName
            FROM Employees;
        `);
        
        // Prompted Claude AI to give code on how to format the dates shorthand:
        sales.forEach(sale => {
            if (sale.saleDate) {
                const date = new Date(sale.saleDate);
                sale.saleDate = date.toLocaleDateString('en-US', { 
                    year: 'numeric', 
                    month: 'short', 
                    day: 'numeric' 
                });
            }
        });
        // Render the sales.hbs file
        res.render('sales', { sales: sales, passes: passes, employees: employees });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});

app.get('/employees', async function (req, res) {
    try {
        // Query all employees
        const query1 = `SELECT idEmployee, lastName, firstName, email, jobTitle, hourlyRate FROM Employees;`;
        const [employees] = await db.query(query1);

        // Render the employees.hbs file with the data
        res.render('employees', { employees: employees });
    } catch (error) {
        console.error('Error executing employee query:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});

app.get('/employees_animals', async function (req, res) {
    try {
        // Create and execute our queries
        // Prompted Claude AI to give code on how to concatenate first name and last names of Employees:
        const query1 = `SELECT Employees_Animals.idEmployeeAnimal, CONCAT(Employees.lastName, ', ', Employees.firstName) AS EmployeeName, Animals.name AS AnimalName
        FROM Employees_Animals
        INNER JOIN Employees ON Employees_Animals.idEmployee = Employees.idEmployee
        INNER JOIN Animals ON Employees_Animals.idAnimal = Animals.idAnimal;`;
        const query2 = 'SELECT * FROM Employees;';
        const query3 = 'SELECT * FROM Animals;';
        const [Employees_Animals] = await db.query(query1);
        const [Employees] = await db.query(query2);
        const [Animals] = await db.query(query3);       

        // Render the employees_animals.hbs file, and also send the renderer
        //  an object that contains animals information
        res.render('employees_animals', { employees_animals: Employees_Animals, employees: Employees, animals: Animals });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// CREATE ROUTES
app.post('/employees/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Cleanse data - If hourlyRate isnt a number, make it NULL.
        if (isNaN(parseFloat(data.create_employee_hourlyRate)))
            data.create_employee_hourlyRate = null;
    

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_CreateEmployee(?, ?, ?, ?, ?, @new_employee_id);`;

        // Store ID of last inserted row
        const [[[rows]]] = await db.query(query1, [
            data.create_employee_lastName,
            data.create_employee_firstName,
            data.create_employee_email,
            data.create_employee_jobTitle,
            data.create_employee_hourlyRate
        ]);

        console.log(`CREATE Employee. ID: ${rows.new_employee_id} ` +
            `Name: ${data.create_employee_firstName} ${data.create_employee_lastName}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/employees');
    } catch (error) {
        console.error('Error creating employee:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while creating the employee.'
        );
    }
});


app.post('/Animals', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Handle NULL case from dropdown
        let dietValue = data.create_animal_diet;
        if (dietValue === '' || dietValue === 'NULL') {
            dietValue = null;
        }

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_CreateAnimal(?, ?, ?, ?, @new_id);`;

        // Store ID of last inserted row
        await db.query(query1, [
            data.create_animal_name,
            data.create_animal_type,
            data.create_animal_dateOfBirth,
            dietValue
        ]);

        // Get the OUT parameter value
        const [result] = await db.query('SELECT @new_id as new_id');
        const newId = result[0].new_id;

        console.log(`CREATE animals. ID: ${newId} ` +
            `name: ${data.create_animal_name}` +
            `diet: ${dietValue}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/Animals');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


app.post('/Food', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_CreateFood(?, ?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[rows]] = await db.query(query1, [
            data.create_food_foodName,
            data.create_food_quantity,
            data.create_food_unit,
        ]);

        console.log(`CREATE Food. ID: ${rows[0].new_id} ` +
            `Name: ${data.create_food_foodName}` +
            `Quantity: ${data.create_food_quantity}` +
            `Unit: ${data.create_food_unit}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/Food');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


app.post('/Employees_Animals', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_CreateEmployeesAnimals(?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[rows]] = await db.query(query1, [
            data.create_employees_animals_idEmployee,
            data.create_employees_animals_idAnimal,
        ]);

        console.log(`CREATE Employees_Animals. ID: ${rows[0].new_id} ` +
            `Employee ID: ${data.create_employees_animals_idEmployee} ` +
            `Animal ID: ${data.create_employees_animals_idAnimal}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/Employees_Animals');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});



// UPDATE ROUTES

app.post('/Animals/update', async function (req, res) {
    try {
        // Parse frontend form information
        const data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = 'CALL sp_UpdateAnimal(?, ?);';

        await db.query(query1, [
            data.update_animal_id,
            data.update_animal_diet,
        ]);

        console.log(`UPDATE Animals. ID: ${data.update_animal_id} ` +
            `New Diet (idFood): ${data.update_animal_diet}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/Animals');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


app.post('/Food/update', async function (req, res) {
    try {
        // Parse frontend form information
        const data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = 'CALL sp_UpdateFood(?, ?, ?);';

        await db.query(query1, [
            data.update_food_id,
            data.update_food_quantity,
            data.update_food_unit
        ]);

        console.log(`UPDATE Food. ID: ${data.update_food_id} ` +
            `New Quantity (idFood): ${data.update_food_quantity}` +
            `New Unit (idFood): ${data.update_food_unit}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/Food');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


app.post('/Employees_Animals/update', async function (req, res) {
    try {
        // Parse frontend form information
        const data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = 'CALL sp_UpdateEmployeesAnimals(?, ?, ?);';

        await db.query(query1, [
            data.update_employees_animals_idEmployee,
            data.update_employees_animals_oldIdAnimal,
            data.update_employees_animals_newIdAnimal
        ]);

        console.log(`UPDATE Employees_Animals. Employee ID: ${data.update_employees_animals_idEmployee} ` +
            `Old Animal ID: ${data.update_employees_animals_oldIdAnimal} ` +
            `New Animal ID: ${data.update_employees_animals_newIdAnimal}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/Employees_Animals');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


// DELETE ROUTES

app.post('/Animals/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_DeleteAnimal(?);`;
        await db.query(query1, [data.delete_animal_id]);

        console.log(`DELETE Animals. ID: ${data.delete_animal_id}`);

        // Redirect the user to the updated webpage data
        res.redirect('/Animals');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


app.post('/Food/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_DeleteFood(?);`;
        await db.query(query1, [data.delete_food_id]);

        console.log(`DELETE Food. ID: ${data.delete_food_id}`);

        // Redirect the user to the updated webpage data
        res.redirect('/Food');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


app.post('/Employees_Animals/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_DeleteEmployeesAnimals(?);`;
        await db.query(query1, [data.delete_employees_animals_idEmployeeAnimal]);

        console.log(`DELETE Employees_Animals. ID: ${data.delete_employees_animals_idEmployeeAnimal}`);

        // Redirect the user to the updated webpage data
        res.redirect('/Employees_Animals');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});



// GET route - shows the reset page
app.get('/Reset', function (req, res) {
    res.render('reset');
});

// POST route - performs the reset

app.post('/Reset', async function (req, res) {
    try {
        
        // Call the reset stored procedure
        await db.query('CALL ResetDatabase();');
        
        console.log('✓ Database reset complete');
        
        // Redirect to home or animals page
        res.redirect('/');
    } catch (error) {
        console.error('Error resetting database:', error);
        res.status(500).send(
            'An error occurred while resetting the database.'
        );
    }
});

// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});
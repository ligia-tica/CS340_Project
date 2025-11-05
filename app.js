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

app.get('/animals', async function (req, res) {
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
            SELECT idSale, idPass, idEmployee, passesSold, saleDate
            FROM Sales;
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


// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});



// File must contain controller in name
module.exports = {

    //GET
    getUsers: async (req, res) => {
        //fetch users

        var users = await User.find();

        res.send(users);
    },

    //POST
    createUser: async (req, res) => {
        //getting parameters in header


        var header = req.headers;
        var username = header['username'];
        var password = header['password'];

        // creating user

        await User.create({
            username: username,
            password: password
        }).exec((err) => {
            //exec == Copmletion
            //returning string status
            if (err != null) {
                return res.send("FAIL" + err);

            }
            res.send("PASS");

        });
    },

    //Delete user rest api
    deleteUser: async (req, res) => {
        var id = req.headers["id"];

        await User.destroy({ id: id }).exec((err) => {
            if (err != null) {
                return res.send("FAIL")
            }
            res.send("PASS");
        })
    }


}

//1.  create DB Model
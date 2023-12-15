        document.addEventListener('DOMContentLoaded', function () {
            const getStudentsBtn = document.getElementById('getStudentsBtn');
            const studentsList = document.getElementById('studentsList');
            const getCoursesBtn = document.getElementById('getCoursesBtn');
            const studentSsnInput = document.getElementById('studentSsn');
            const coursesList = document.getElementById('coursesList');
            const registerForm = document.getElementById('registerForm');
        
            getStudentsBtn.addEventListener('click', function () {
                fetch('/students')
                    .then(response => response.json())
                    .then(data => {
                        console.log(data);
                        // Updatera User interface med student data
                        studentsList.innerHTML = ''; // rensa tidigare innehåll
                        data.forEach(student => {
                            studentsList.innerHTML += `<p>${student[1]}</p>`;
                        });
                    })
                    .catch(error => console.error('Error:', error));
            });
        
            getCoursesBtn.addEventListener('click', function () {
                const studentSsn = studentSsnInput.value;
                fetch(`/student/${studentSsn}/courses`)
                    .then(response => response.json())
                    .then(data => {
                        console.log(data);
                        // Updatera User interface med student courses data
                        coursesList.innerHTML = ''; // rensa tidigare innehåll
                        data.forEach(course => {
                            coursesList.innerHTML += `<p>${course[0]}</p>`;
                        });
                    })
                    .catch(error => console.error('Error:', error));
            });
        
            registerForm.addEventListener('submit', function (event) {
                event.preventDefault();
                const formData = new FormData(registerForm);
        
                fetch('/register_student', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams(formData).toString(),
                })
                    .then(response => response.json())
                    .then(data => {
                        console.log(data);
                        // updatera User interface efter behov
                    })
                    .catch(error => console.error('Error:', error));
            });
        });
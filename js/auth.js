async function checkSession() {
    const { data: { session } } = await db.auth.getSession();
    if (session) { window.location.href = 'app.html'; }
}

async function login() {
    const email = document.getElementById('loginEmail').value.trim();
    const password = document.getElementById('loginPassword').value;
    if (!email || !password) { mostrarError('Introduce tu email y contraseña'); return; }

    const btn = document.querySelector('.btn-primary');
    btn.textContent = 'Entrando...';
    btn.disabled = true;

    const { data, error } = await db.auth.signInWithPassword({ email, password });
    if (error) {
        mostrarError('Email o contraseña incorrectos');
        btn.textContent = 'Entrar';
        btn.disabled = false;
        return;
    }

    const { data: perfil } = await db
        .from('perfiles')
        .select('*')
        .eq('id', data.user.id)
        .single();

    localStorage.setItem('perfil', JSON.stringify(perfil));
    window.location.href = 'app.html';
}

async function logout() {
    await db.auth.signOut();
    localStorage.removeItem('perfil');
    window.location.href = 'index.html';
}

function mostrarError(msg) {
    const errorDiv = document.getElementById('loginError');
    errorDiv.textContent = msg;
    errorDiv.style.display = 'block';
}

checkSession();
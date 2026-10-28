# Inception - User Documentation

If the stack is not set up yet, see [DEV_DOC](DEV_DOC.md).

## What the stack provides

The stack runs a WordPress website with three services:

- **NGINX**: the front door. It handles the secure HTTPS connection.
- **WordPress**: the website and its admin panel.
- **MariaDB**: the database. It stores posts, pages, users and comments.

The only way to reach the site is **https://ggalizon.42.fr**. The `http://` address does not work, and the database cannot be reached from outside.

## Start and stop

Run these commands from the root of the repository.

To build and start everything:
```bash
make
```
The first start can take a few minutes. If you see a "502 Bad Gateway" error, wait a minute and reload the page.

To stop the site (the site content is kept):
```bash
make down
```

To stop the site and delete the built images (the site content is kept, and the next `make` builds everything again):
```bash
make clean
```

> **Warning:** `make fclean` deletes everything, including all site content (posts, users, comments). It asks for your sudo password. Only use it if you want to start from zero.

## Access the site and admin panel

- Website: https://ggalizon.42.fr
- Admin panel: https://ggalizon.42.fr/wp-admin

The browser will show a security warning because the certificate is self-signed. This is expected. To continue:

- Firefox: click **Advanced**, then **Accept the Risk and Continue**.
- Chrome: click **Advanced**, then **Proceed to ggalizon.42.fr**.
- Safari: click **Show Details**, then **visit this website**.

The warning can come back after you stop and start the site again.

## Credentials

| Account | Username | Password file |
|---|---|---|
| WordPress admin | `giulia` | `secrets/wp_admin_password.txt` |
| WordPress user (Author) | `mainuser` | `secrets/wp_user_password.txt` |
| Database user | `mysiteuser` | `secrets/db_password.txt` |
| Database root | `root` | `secrets/db_root_password.txt` |

Usernames and emails are in `srcs/.env`. The `srcs/.env` file and the `secrets/` folder are not in Git. They only exist on this machine.

### Change a WordPress password

The password files are only read the first time the site is installed. Changing a file later does not change the password.

1. Log in to the admin panel as `giulia`.
2. Go to **Users**, then click **Edit** under the user.
3. Click **Set New Password**, type the new password, then click **Update User**.
4. Write the new password in the matching file in `secrets/`, so the file stays correct.


## Check that it works

Check the status of the services:
```bash
make ps
```
You should see `mariadb`, `wordpress` and `nginx` running. Only `mariadb` shows "(healthy)". The other two show "Up".

Then:

1. Open https://ggalizon.42.fr. You should see the website, not the WordPress installation page.
2. Log in at https://ggalizon.42.fr/wp-admin as `giulia`.
3. Log in as `mainuser` and leave a comment on a post.

To see the logs of the services:
```bash
make logs
```
Press **Ctrl+C** to stop.

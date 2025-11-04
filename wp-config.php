<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress');

/** Database username */
define('DB_USER', 'annetcheby');

/** Database password */
define('DB_PASSWORD', 'Francoise123!');

/** Database hostname */
define('DB_HOST', 'wordpressnancy.c8x2s4kiedw0.us-east-1.rds.amazonaws.com');

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

define('AUTH_KEY',         '9!ITK@g|N|JNh#!][EqX2pVG&IU1hYdv@UtQ.[hmAiU<7G_gwS7p/@D^|*4sg!m9');
define('SECURE_AUTH_KEY',  '!s/8=22A/3Ph&M-@J29BvE7H<!fc2R9dCO2p3-z$aF0;_TH}_+jCx1M~3#f#-Mvt');
define('LOGGED_IN_KEY',    'f[}z*n/_1MO7s+hu2|pV4md?Q4=)xU@>x0N`$r+809/*(Yuq<FLL2sKxFYf$zhY`');
define('NONCE_KEY',        '2Moi(i+9S+-:iwuU&%U31<DU(ToCw<sr9-|kqG_vqW]tf`9[NzF34%>B]7kZf3?R');
define('AUTH_SALT',        'KdR%sr+:0vRn@Eu@+2ErzOP%{^W^B+NK>X`$C*eaO^ 0V4(^8w%U+np:i|OS9*21');
define('SECURE_AUTH_SALT', 'Lx8RdRGz*c.Ny8S/@g}$ *nh!^B_@6UJYYf=k}F,*27[#z(|Q;17zM,?D?&Z^d_a');
define('LOGGED_IN_SALT',   'TASK ,z_&3bAJ -XPo;X<7jGCy<*4q0!U:1dD{Nv* Zx| hL9~&~~o4%@}*ddY3;');
define('NONCE_SALT',       '!{<Al.++qU]cZ$/ Fn9Cuw{dlT(WcmmX}*wz*B<>Q*X=XW_`=7jEiN2sYYxwoPi[');
/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

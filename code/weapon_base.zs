/*
===============================================================================
WEAPON_BASE.TXT  Sistema base de armas y munición
===============================================================================

Este archivo define:

1) La clase base de todas las armas del mod.
2) La jerarquía completa de munición, cajas, pickups y munición interna.
3) El estándar de comportamiento compartido (bob, zoom, lowering).
4) La convención de sprites e inventario utilizada en todo el proyecto.

-------------------------------------------------------------------------------
1. CLASE BASE DE ARMAS
-------------------------------------------------------------------------------

class weapon_base : weapon replaces Doomweapon

Propósito:
- Centralizar comportamiento común a TODAS las armas.
- Evitar duplicación de lógica en cada clase individual.
- Permitir cambios globales de balance y feel desde un solo lugar.

Variables internas:
- bool Zoomed
    Indica si el arma se encuentra en modo apuntado.
- bool Rifle_Firemode
    Controla modos de disparo (auto / ráfaga).
- bool First_Shot_Pumped
    Usado para lógica de bombeo inicial (escopetas).
- bool Dual_Shotgun_FireMode
    Controla comportamiento alternativo de escopetas dobles.

Bloque default:
- Define el comportamiento de bobbing común:
    weapon.bobstyle "Smooth"
    weapon.bobspeed 3
    weapon.bobrangey 1.2
    weapon.bobrangex 0.8

Nota:
El idle del arma es estático; el movimiento se delega al sistema de bobbing
para mantener consistencia visual y reducir sprites innecesarios.

Acción personalizada:
- a_lower2()
    Fuerza la salida del modo zoom antes de bajar el arma.
    Previene estados inconsistentes al cambiar de arma.

-------------------------------------------------------------------------------
2. SISTEMA DE MUNCIÓN BASE (REEMPLAZOS DE DOOM)
-------------------------------------------------------------------------------

Las clases de munición reemplazan directamente las originales de Doom
para mantener compatibilidad con mapas vanilla.

Ejemplo:
- Rifle_bullets reemplaza clip
- Shotgun_Shell reemplaza shell
- lazer_ammo reemplaza cell

Características comunes:
- inventory.amount         Cantidad al recoger
- inventory.maxamount      Capacidad máxima
- ammo.backpackamount      Cantidad con mochila
- ammo.backpackmaxamount   Capacidad máxima con mochila
- inventory.pickupmessage  Mensaje localizado
- inventory.pickupsound    Sonido de pickup
- inventory.icon           Icono HUD (catálogo 1)

Sprites de mundo:
- Usan el catálogo 2 (I2****)
- Frame infinito (-1) para objetos estáticos en el mapa

-------------------------------------------------------------------------------
3. CAJAS DE MUNICIÓN
-------------------------------------------------------------------------------

Las cajas heredan de su tipo de munición base y solo modifican:
- inventory.amount
- pickupmessage
- pickupsound

Esto garantiza:
- Balance consistente
- Cambios globales fáciles (una clase base, múltiples variantes)

Caso especial:
- rocket_box_spawner
    Decide dinámicamente si spawnea rockets o misiles.
    Evita duplicar spawns en mapas y añade variabilidad.

-------------------------------------------------------------------------------
4. MUNICIÓN SUELTA (PICKUPS PEQUEÑOS)
-------------------------------------------------------------------------------

Clases como:
- rifle_bullet_clip
- single_Shotgun_Shell

Usadas para:
- Drops de enemigos
- Recompensas menores
- Ajuste fino del ritmo de recursos

Comparten la misma munición base, solo cambia la cantidad.

-------------------------------------------------------------------------------
5. MUNICIÓN INTERNA DE ARMAS
-------------------------------------------------------------------------------

Estas clases NO representan pickups del mundo.

Propósito:
- Definir capacidad del cargador interno de cada arma.
- Separar munición en mochila vs munición cargada.

Ejemplos:
- rifle_ammo       maxamount 31 (30 + 1 en recámara)
- FAL_ammo         maxamount 21
- shotgun_ammo     maxamount 8
- super_shotgun_ammo maxamount 2

Esto permite:
- Recargas realistas
- Estados intermedios (recámara, vacío, etc.)
- Lógica de interrupción de disparo / recarga precisa

-------------------------------------------------------------------------------
6. CONVENCIÓN DE SPRITES
-------------------------------------------------------------------------------

===============================================================================
 ITEM NAMING CONVENTION  GLOBAL RULESET
===============================================================================

Todos los sprites de ítems (HUD y mundo) siguen una convención estricta
de nombres para asegurar:

- Orden lógico
- Lectura inmediata
- Escalabilidad
- Compatibilidad con weapon_base y futuros sistemas

FORMATO GENERAL:
----------------
I<Cat><ID><Var>

Ejemplo:
I2CLB
I1SHA
I3RKA

DESGLOSE:
---------

1) I
   Prefijo fijo.
   Indica que el sprite corresponde a un ÍTEM (pickup, HUD o world actor).

2) <Cat> (1 dígito)
   Catálogo funcional del ítem:

   1 = HUD icons
       (representaciones gráficas de munición, armas, llaves, armaduras)

   2 = Recursos y munición (actors en el mundo)
       (balas, cartuchos, celdas, cohetes, misiles, mochilas)

   3 = Armas y piezas de armas (actors en el mundo)

   4 = Objetos de supervivencia
       (armaduras, vida, medkits)

   5 = Powerups y efectos temporales
       (invulnerabilidad, berserk, efectos especiales)

3) <ID> (2 caracteres)
   Identificador del objeto.
   No tiene significado semántico por sí solo fuera del contexto del mod.

   Ejemplos:
   CL = Rifle bullets / clips
   SH = Shotgun shells
   RK = Rockets / Missiles
   CE = Cells / Energy
   LZ = Laser-related ammo

4) <Var> (1 letra AZ)
   Variante del objeto dentro de su catálogo.

   REGLA CLAVE PARA CATÁLOGO 2 (MUNICIÓN):
   --------------------------------------
   Las variantes se ordenan de MENOR a MAYOR cantidad entregada.

   A = menor cantidad
   B = cantidad intermedia
   C = mayor cantidad
   (y así sucesivamente si fuese necesario)

   Ejemplo (rifle ammo):
   I2CLA = magazine (30)
   I2CLB = ammo box (100)
   I2CLC = small clip (5)

NOTAS IMPORTANTES:
------------------
- El orden de letras NO es estético, es funcional.
- La letra indica jerarquía de cantidad, no tipo narrativo.
- El mismo ID puede existir en distintos catálogos sin conflicto.
- Los props decorativos NO usan este sistema (tienen su propio esquema).

===============================================================================

-------------------------------------------------------------------------------
7. FILOSOFÍA DE DISEÑO
-------------------------------------------------------------------------------

- El motor corre a 35 ticks: el ritmo importa más que la fluidez.
- Cada frame debe justificar su existencia.
- La lectura visual prima sobre el realismo.
- La jerarquía de armas se comunica por ritmo, daño, retroceso y zoom,
  no solo por números.

Este archivo es la columna vertebral del sistema de armas.
Cualquier cambio aquí impacta TODO el mod.

Tocar con respeto.
===============================================================================
*/


class weapon_base : weapon replaces Doomweapon
{
	bool Zoomed;
	bool Rifle_Firemode;
	bool First_Shot_Pumped;
	bool Dual_Shotgun_FireMode;
	
	default
	{
		weapon.bobstyle "Smooth";
		weapon.bobspeed 3;
		weapon.bobrangey 1.2;
		weapon.bobrangex 0.8;
	}
	
	action void a_lower2()
	{
		invoker.Zoomed = false;
		a_zoomfactor(1.0);
		a_lower();
	}
	
	action void a_firerpg69missile(int count = 1)
	{
		if (invoker.ammo2 && invoker.ammo2.amount < 1)
		{
			player.setpsprite(PSP_WEAPON, invoker.FindState("Ready"));
			return;
		}
		A_FireProjectile("RPG69_missile", random(-3, 3));
		//A_TakeInventory(invoker.AmmoType2, 1);
		
	}
}
// municion base
class Rifle_bullets : ammo replaces clip
{
	default
	{
		inventory.amount 30;
		inventory.maxamount 300;
		ammo.backpackamount 60;
		ammo.backpackmaxamount 600;
		
		inventory.pickupmessage "$got_pick_clip";
		inventory.pickupsound "items/clippick";
		inventory.icon "I1CLA0";
	}
	states
	{
	spawn:
		I2CL B -1;
		stop;
	}
}
class Shotgun_Shell : ammo replaces shell
{
	default
	{
		inventory.amount 4;
		inventory.maxamount 40;
		ammo.backpackamount 8;
		ammo.backpackmaxamount 120;
		
		inventory.pickupmessage "$got_pick_shell";
		inventory.pickupsound "items/shellpick";
		inventory.icon "I1SHA0";
	}
	states
	{
	spawn:
		i2sh B -1;
		stop;
	}
}
class rocket_ammo : ammo replaces rocketammo
{
	default
	{
		inventory.amount 1;
		inventory.maxamount 25;
		ammo.backpackamount 4;
		ammo.backpackmaxamount 50;
		
		inventory.pickupmessage "$got_pick_rocket";
		inventory.pickupsound "items/rockpick";
		inventory.icon "I1RKA0";
	}
	states
	{
	spawn:
		i2rk a -1;
		stop;
	}
}
class missile_ammo : ammo
{
	default
	{
		inventory.amount 4;
		inventory.maxamount 40;
		ammo.backpackamount 16;
		ammo.backpackmaxamount 80;
		
		inventory.pickupmessage "$got_pick_missile";
		inventory.pickupsound "items/missilepick";
		inventory.icon "I1MKA0";
	}
	states
	{
	spawn:
		i2mk a -1;
		stop;
	}
}
class lazer_ammo : ammo replaces cell
{
	default
	{
		inventory.amount 40;
		inventory.maxamount 400;
		ammo.backpackamount 80;
		ammo.backpackmaxamount 800;
		
		inventory.pickupmessage "$got_pick_cell";
		inventory.pickupsound "items/cellpick";
		inventory.icon "I1CEA0";
	}
	states
	{
	spawn:
		i2ce A -1;
		stop;
	}
}
//cajas de municion
class rifle_bullets_box : Rifle_bullets replaces clipbox
{
	default
	{
		inventory.amount 100;
		inventory.pickupmessage "$got_pick_clipbox";
		inventory.pickupsound "items/clipboxpick";
	}
	states
	{
	spawn:
		i2cl C -1;
		stop;
	}
}
class shotgun_shell_box : Shotgun_Shell replaces shellbox
{
	default
	{
		inventory.amount 20;
		inventory.pickupmessage "$got_pick_shellbox";
		inventory.pickupsound "items/shellboxpick";
	}
	states
	{
	spawn:
		i2sh C -1;
		stop;
	}
}
class rocket_box_spawner : actor replaces rocketbox
{
	default
	{
		+noblockmap;
	}
	states
	{
	spawn:
		tnt1 a 1 a_jump(200,"spawn1","spawn2");
		goto spawn1;
		
	spawn1:
		tnt1 a 1 a_spawnitem("rocket_ammo_box");
		stop;
		
	spawn2:
		tnt1 a 1 a_spawnitem("missile_ammo_box");
		stop;
	}
}
class rocket_ammo_box : rocket_ammo
{
	default
	{
		inventory.amount 5;
		inventory.pickupmessage "$got_pick_rocketbox";
		inventory.pickupsound "items/rockboxpick";
	}
	states
	{
	spawn:
		i2rk b -1;
		stop;
	}
}
class missile_ammo_box : missile_ammo
{
	default
	{
		inventory.amount 8;
		inventory.pickupmessage "$got_pick_missilebox";
		inventory.pickupsound "items/missileboxpick";
	}
	states
	{
	spawn:
		I2mK b -1;
		stop;
	}
}
class lazer_ammo_box : lazer_ammo replaces cellpack //BATERIA GIGANTE
{
	default
	{
		inventory.amount 100;
		inventory.pickupmessage "$got_pick_cellbox";
		inventory.pickupsound "items/cellboxpick";
	}
	states
	{
	spawn:
		I2CE B -1;
		stop;
	}
}
//balas sueltas
class rifle_bullet_clip : Rifle_bullets
{
	default
	{
		inventory.amount 5;
		inventory.pickupmessage "$got_pick_bullet_clip";
		inventory.pickupsound "items/bulletpick";
		+INVENTORY.IGNORESKILL
	}
	states
	{
	spawn:
		i2cl A -1;
		stop;
	}
}
class single_Shotgun_Shell : Shotgun_Shell
{
	//$category "amunition"
	default
	{
		inventory.amount 1;
		inventory.pickupmessage "$got_pick_single_shell";
		inventory.pickupsound "items/singleshellpick";
		+INVENTORY.IGNORESKILL
	}
	states
	{
	spawn:
		i2sh A -1;
		stop;
	}
}	

//municion interna del arma
class rifle_ammo : ammo
{
	default
	{
		inventory.maxamount 31;
	}
}
class AK_ammo : ammo
{
	default
	{
		inventory.maxamount 31;
	}
}
class FAL_ammo : ammo
{
	default
	{
		inventory.maxamount 21;
	}
}
class UAC_rifle_ammo : ammo
{
	default
	{
		inventory.maxamount 26;
	}
}
class shotgun_ammo : ammo
{
	default
	{
		inventory.maxamount 8;
	}
}
class dual_shotgun_ammo : ammo
{
	default
	{
		inventory.maxamount 12;
	}
}
class super_shotgun_ammo : ammo
{
	default
	{
		inventory.maxamount 2;
	}
}
class machinegun_ammo : ammo
{
	default
	{
		inventory.maxamount 90;
	}
}
class lazergun_ammo : ammo
{
	default
	{
		inventory.maxamount 40;
	}
}
class Lazorgun_ammo : ammo
{
	default
	{
		inventory.maxamount 4;
	}
}
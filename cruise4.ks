//Copyright (c) Freze http://kerbalspace.ru/ freze.special@gmail.com.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

//Version 3.1





//Дистанция загрузки крафтов
//set loaddistance to 100000.


//передаем ссылку на цель
parameter targ.
//или сами ее выбираем
//list targets in ta.
//set targ to ta[9].
//или помечаем мышкой
//set targ to target.




set ang to 60. //угол запуска
set Kang to 1.//Коэффициэнт максимального угла атаки
set start_alt to ship:altitude + 20. //активация на высоте + 20м
set traj to "H".//По умолчанию траектория полета - высокая.
set phase to 1.//Фаза полета

//По умолчанию профиль полета - высокий
set targ_alt to 18000. //желаемая высота
set targ_speed to 1500. //желаемая скорость

//Переменные ПИД-Регулятора
LOCK Pa TO (targ_alt - ship:altitude).//Разница высот
SET Ia TO 0.
SET Da TO 0.
SET P0a TO Pa.
LOCK Ps TO (targ_speed-ship:airspeed).//Разница скоростей
SET Is TO 0.
SET Ds TO 0.
SET P0s TO Ps.

//Мертвая зона ПИД-регулятора
LOCK in_deadbanda TO ABS(Pa) < 0.01.
LOCK in_deadbands TO ABS(Ps) < 0.01.

//Коэффициеты ПИД-Регулятора
SET Kpa TO 0.001.
SET Kia TO 0.//0.00000005.
SET Kda TO 0.01.
SET Kps TO 0.001.
SET Kis TO 0.//0.0000002.
SET Kds TO 0.006.

set maxang to 60.

//Вычисление дельны по тяге и углу атаки
LOCK dtang TO Kpa * Pa + Kia * Ia + Kda * Da.
LOCK dthrott TO Kps * Ps + Kis * Is + Kds * Ds.

//Выбираем низкую. траекторию если цель не дальше 100км и ниже 10м (надводная)
if targ:distance < 140000 and targ:distance > 20000 and targ:altitude < 10 {set traj to "L".}

//косталь автопуска.
wait 5.
lock throttle to 1. 
for skip in ship:partsnamed("engineLargeSkipper"){ skip:activate.}
wait 1.
for sep in ship:partsnamed("stackSeparatorMini") { sep:getmodule("ModuleDecouple"):doaction("Decouple", true).}
unlock throttle.

//Ждем выброса ракеты вверх
wait until ship:altitude > start_alt or ship:altitude < start_alt - 120.



sas on.//включаем сас

//Врубаем тягу, направление - на цель, угол для набора высоты
set throttle to 1.
lock course to targ:heading.
lock steering to heading(course, ang).

//твердотопливные ускорители
wait 1.5.
//stage.
for booster in ship:partsnamed("sepMotor1") {  booster:activate.}//Включаем все Sepratron-1
for booster in ship:partsnamed("solidBooster.sm") {  booster:activate.}//Включаем все Flea

//включаем рапиру
wait until ship:solidfuel < 1.
//stage.
for decoupler in ship:partsnamed("stackDecoupler") {  decoupler:getmodule("ModuleDecouple"):doaction("Decouple", true).}//отбрасываем все декуплеры TR-18A
for rap in ship:partsnamed("RAPIER") {  rap:activate.}//включаем все рапиры


//ждем набора высоты
wait until ship:altitude > start_alt + 780.

//полет
set thrott to 1.
lock throttle to thrott.//фиксируем тягу.

//lock maxang to 60.
lock maxang to max(3 * Kang, min(60, abs(3*((targ_alt-ship:altitude)*(targ_alt-ship:altitude)/1000000)+1))) . //ограничение макс угла атаки в зависимости от  разницы требуемой высоты и текущий, не дает ракете резко маниврировать для набора\сброса маленькой разницы высот. угол не может быть менеше 3 * коэффициент.
//lock maxang to max(3, min(60, (((targ_alt - ship:altitude)/1000*1.25)+40) / (0.00018 * ship:altitude/1000 * ship:altitude/1000 * ship:altitude/1000 * ship:altitude/1000 + 1))). //ограничение макс угла атаки в зависимости от  dh.

lock compensated_vec to targ:direction:forevector + (targ:direction:forevector - ship:srfprograde:vector).//вычисляем поправку для атаки с пикирования. ох, бля, и почему я раньше не знал о srfprograde? оО.

//фаза 2
when targ:distance < 125000 and phase = 1 then{
set phase to 2.
//set targ_alt to 8000.
//set targ_speed to 1000.
}

//фаза 3
when targ:distance < 75000 and phase = 2 then{
set phase to 3.
if traj = "L" {
	//set targ_alt to 3000.
	//set targ_speed to 500.
	set targ_alt to 8000.
	set targ_speed to 1000.
}
else{}
}

//фаза 4
when targ:distance < 50000 and phase = 3 then{
set phase to 4.
if traj = "L" {
	set targ_alt to 50.
	set targ_speed to 500.
	lock targ_alt to max(ship:altitude - alt:radar + 50, 50).// устанавливаем высоту на 50 метров выше поверхности
	set Kang to 3.//добавляем множитель к ограничителя угла атаки. при полете вдоль рельефа нам нужна быстрая реакция
	//lock targ_alt to max(min(alt:radar, ship:altitude) + 50, 50).
}
else{
	//set targ_alt to 3000 + targ:altitude.
	//set targ_speed to 500.
	set targ_alt to 8000.
	set targ_speed to 1000.
}
//огибание рельефа. НЕ ТЕСТИРОВАЛОСЬ!!! должно работать только в 3й фазе полета
//if alt:radar < ship:altitude {lock targ_alt to alt:radar - ship:altitude + 50.}
//else { set targ_alt to 50.}
//preserve.
}

//фаза 5
when targ:distance < 22500 and phase = 4 then{
if traj = "L" {
	sas off.
	lock targ_alt to 2.2.
	set Kang to 1.
	set targ_speed to 500.
}
else{
	set phase to 5.
	set targ_alt to 3000 + targ:altitude.
	set targ_speed to 500.
}
}

//самонаведение для заключительного участка. при низком профиле полета не используется.
when targ:distance < 8000 and phase = 5 then {
//lock steering to heading(course, arcsin((sqrt((targ:distance * targ:distance) - ((ship:altitude - targ:altitude) * (ship:altitude - targ:altitude))) + 4) / targ:distance) - 90).
lock steering to compensated_vec:direction.//берем поправку.
sas off.
}


//инициализация таймеров
SET t0a TO TIME:SECONDS.
SET t0s TO TIME:SECONDS.


//ПИД-Регулятор. бесконечный цикл.
until false {
	clearscreen.
	//обновляем разницу времени с последнего вычисления
	SET dta TO TIME:SECONDS - t0a.
	SET dts TO TIME:SECONDS - t0s.
	//для высоты. Вычисляем тангаж.
	IF dta > 0 {//прошло хоть чуть-чуть времени
		IF NOT in_deadbanda {//и его достаточно много
			SET Ia TO Ia + Pa * dta.//пропорциональная составляющая
			SET Da TO (Pa - P0a) / dta.//дифференциальная состовляющая
			IF Kia > 0 {SET Ia TO MIN(1.0/Kia, MAX(-1.0/Kia, Ia)).}//интегральная составляющая
			SET ang to MIN(maxang, MAX(-maxang, ang + dtang)).//если тангаж большой, ограничеваем его макс углом.
			//обновляем переменные
			SET P0a TO Pa.
			SET t0a TO TIME:SECONDS.
		}
	}
		//для скорости. Вычисляем тягу.
	IF dts > 0 {//прошло хоть чуть-чуть времени
		IF NOT in_deadbands {//и его достаточно много
			SET Is TO Is + Ps * dts.//пропорциональная составляющая
			SET Ds TO (Ps - P0s) / dts.//дифференциальная состовляющая
			IF Kis > 0 {SET Is TO MIN(1.0/Kis, MAX(-1.0/Kis, Is)).}//интегральная составляющая
			SET thrott to MIN(1, MAX(0, thrott + dthrott)).//ограничиваем тягу отрезком [0:1]
			//обновляем переменные
			SET P0s TO Ps.
			SET t0s TO TIME:SECONDS.
		}
	}
	//debug
	//print "Kp*P a:= "+round(Kpa*Pa, 3).
	//print "Ki*I a:= "+round(Kia*Ia, 3).
	//print "Kd*D a:= "+round(Kda*Da, 3).
	//print "Kp*P s:= "+round(Kps*Ps, 3).
	//print "Ki*I s:= "+round(Kis*Is, 3).
	//print "Kd*D s:= "+round(Kds*Ds, 3).
	//print "maxAng:= "+round(maxang).
	//print "-------------------------------".
	print targ:distance.
	print "-------------------------------".
	print ship:altitude.
	print ship:airspeed.
	print "-------------------------------".
	print targ_alt.
	print targ_speed.
	print "-------------------------------".
	Print "ETA: " + targ:distance/ship:airspeed.
	print "-------------------------------".
	print traj.
	print phase.
	//print ship:direction:forevector:x - targ:direction:forevector:x  + "  " + ship:direction:forevector:y - targ:direction:forevector:y + "  " + ship:direction:forevector:z - targ:direction:forevector:z.
	//print (((targ_alt - ship:altitude)/1000*1.25)+40).
	//print  (0.00018 * ship:altitude/1000 * ship:altitude/1000 * ship:altitude/1000 * ship:altitude/1000 + 1).
	
	//ждем немного времени
	WAIT 0.001.
}
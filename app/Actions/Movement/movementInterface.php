<?php

namespace App\Actions\Movement;

interface movementInterface
{
    public function getPosition();
    public function getVelocity();
    public function setVelocity();
    public function move();
}

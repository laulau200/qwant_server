<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\FrameworkBundle\Controller\abstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class homeController extends AbstractController{

#[Route("/", name: "home_index")]
public function show(int $id): Response{
        return $this->render( view: '/public/index.html.twig', [
            'controller_name' => 'HomeController',
        ]);
    }
}

#[Route("/contact", name: "contact")]
public function show(int $id): Response{
        return $this->render( view: '/public/contact.html.twig', [
            'controller_name' => 'HomeController',
        ]);
    }

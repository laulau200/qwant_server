<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\FrameworkBundle\Controller\abstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class contactController extends AbstractController{

#[Route("/contact",name: 'contact')]
     public function show(): Response{
    return $this->render( view: '/public/contact.html.twig', [
            'controller_name' => 'ContactController',
        ]);
     }
    }

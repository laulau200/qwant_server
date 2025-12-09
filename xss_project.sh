#!/bin/bash

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: ./generate_symfony_xss_project.sh nom_du_projet"
  exit 1
fi

echo "?? Création du projet Symfony..."
composer create-project symfony/webapp-pack $PROJECT_NAME

cd $PROJECT_NAME || exit

echo "?? Installation des protections XSS..."
composer require nelmio/security-bundle
composer require ezyang/htmlpurifier

echo "?? Création des dossiers..."
mkdir -p config/packages
mkdir -p src/Service
mkdir -p src/Form
mkdir -p src/Controller
mkdir -p templates/message

echo "??? Ajout du fichier CSP..."
cat > config/packages/nelmio_security.yaml << 'EOF'
nelmio_security:
    csp:
        enabled: true
        content_security_policy:
            default-src: ['self']
            script-src:
                - 'self'
                - 'nonce'
            style-src: ['self']
            img-src: ['self', 'data:']
            object-src: ['none']
EOF

echo "?? Ajout du service HTMLPurifier..."
cat > src/Service/HtmlSanitizer.php << 'EOF'
<?php

namespace App\Service;

use HTMLPurifier;
use HTMLPurifier_Config;

class HtmlSanitizer
{
    private HTMLPurifier $purifier;

    public function __construct()
    {
        $config = HTMLPurifier_Config::createDefault();
        $config->set('HTML.Allowed', '');
        $this->purifier = new HTMLPurifier($config);
    }

    public function clean(string $text): string
    {
        return $this->purifier->purify($text);
    }
}
EOF

echo "?? Ajout du formulaire..."
cat > src/Form/MessageType.php << 'EOF'
<?php

namespace App\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;

class MessageType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder->add('content', TextareaType::class, [
            'label' => 'Votre message'
        ]);
    }
}
EOF

echo "?? Ajout du contrôleur..."
cat > src/Controller/MessageController.php << 'EOF'
<?php

namespace App\Controller;

use App\Form\MessageType;
use App\Service\HtmlSanitizer;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class MessageController extends AbstractController
{
    #[Route('/message', name: 'app_message')]
    public function index(Request $request, HtmlSanitizer $sanitizer): Response
    {
        $form = $this->createForm(MessageType::class);
        $form->handleRequest($request);

        $clean = null;

        if ($form->isSubmitted() && $form->isValid()) {
            $clean = $sanitizer->clean($form->get('content')->getData());
        }

        return $this->render('message/index.html.twig', [
            'form' => $form->createView(),
            'safeMessage' => $clean,
        ]);
    }
}
EOF

echo "?? Ajout template base..."
cat > templates/base.html.twig << 'EOF'
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>XSS Project</title>
    </head>
    <body>
        {% block body %}{% endblock %}
    </body>
</html>
EOF

echo "?? Ajout template message..."
cat > templates/message/index.html.twig << 'EOF'
{% extends 'base.html.twig' %}

{% block body %}
<h1>Envoyez un message</h1>

{{ form_start(form) }}
{{ form_row(form.content) }}
<button>Envoyer</button>
{{ form_end(form) }}

{% if safeMessage %}
<h2>Message nettoyé :</h2>
<div>{{ safeMessage }}</div>
{% endif %}

<script nonce="{{ csp_nonce('script') }}">
console.log("CSP Actif");
</script>

{% endblock %}
EOF

echo "?? Projet généré avec succès dans : $PROJECT_NAME"

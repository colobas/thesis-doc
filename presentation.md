---
title: Variational Mixture of Normalizing Flows
author: Guilherme Grijó Pen Freitas Pires
logo: '`\includegraphics[width=0.2\textwidth]{figures/logo_ist.jpg}`{=latex}'
toc: true
---
## Summary

This work in one sentence:
\begin{itemize}
    \item The development of a mixture of \textbf{normalizing flows}
    and a (variational) training procedure for it.
\end{itemize}

# Introduction and Motivation

## Introduction and Motivation

\begin{itemize}
\onslide<1->{\item Deep generative models have been an active area of research, with promising
results.}
    \begin{itemize}
        \onslide<2->{\item Implicit distributions: Generative adversarial networks
            \autocites{GAN}, Variational Autoencoder \autocites{vaepaper}
            \begin{itemize} \item Don't allow explicit access to the density function \end{itemize}}
        \onslide<3->{\item Explicit distributions: Normalizing flows
            \autocites{shakir_nf}
            \begin{itemize} \item Allow explicit access to the density function \end{itemize}}
    \end{itemize}
\end{itemize}

## Introduction and Motivation

\begin{itemize}
\onslide<1->{\item This work}
    \begin{itemize}
        \onslide<2->{\item How to endow normalizing flows with discrete structure?}
        \onslide<3->{\item Or, how to endow mixture models with more expressiveness/flexibility?}
    \end{itemize}
\end{itemize}

## Outline

\begin{itemize}
\onslide<1->{\item Introductory concepts on probabilistic modelling}
\onslide<2->{\item Variational Inference}
    \onslide<3->{\begin{itemize} \item The chosen method for optimizing the model proposed in this work \end{itemize}}
\onslide<4->{\item Normalizing Flows}
    \onslide<5->{\begin{itemize} \item The centerpiece of the proposed model \end{itemize}}
\onslide<6->{\item Variational Mixture of Normalizing Flows}
\onslide<7->{\item Experiments and results}
\onslide<8->{\item Conclusions and future work}
\end{itemize}

# Probabilistic Modelling

## Probabilistic Modelling: Goal

Given data, find the probability distribution (commonly referred to as the
*model*) that is the closest possible approximation to the true distribution
of the data.

## Probabilistic Modelling: Goal

Informally, via Bayes' Law:

\begin{align*}
    p(\mbox{hypothesis}|\mbox{data}) = \frac{p(\mbox{data}|\mbox{hypothesis})p(\mbox{hypothesis})}{p(\mbox{data})} \label{eq:bayes}.
\end{align*}

. . .

The goal of probabilistic modelling is to find the optimal hypothesis that
maximizes (some form of) this expression.

## Probabilistic Modelling: Hypothesis

There are infinite candidate distributions to model the data. In practice,
the scope is narrowed to a class of hypothesis.

. . .

\begin{itemize}[<+->]
    \item Parametric families: $p(\bm{x}|\bm\theta)$
    \item Particular factorizations: e.g. $p(\bm{x}) = \prod_i^N p(x_i|x_{i-1})$
    \item Latent variables: $p(\bm{x}) = \int p(\bm{x}, \bm{z}) d\bm{z}$\footnote<4->{In
    the case of discrete latent variables, the integral becomes a sum}
    \item All of the above, combined
\end{itemize}

## Probabilistic Modelling: Hypothesis

Example: Mixture Models.

. . .

A mixture model is defined as:
\begin{align*}
    p(\bm{x}, \bm{z}) = p(\bm{x}|\bm{z}, \bm\theta) p(\bm{z})
\end{align*}

. . .

\centering
\includegraphics[width=0.5\textwidth]{figures/plate_diagram2.png}

## Probabilistic Modelling: Parameter Estimation

Given data $\bm{x}$ and a parametric model $p(\bm{x}| \bm\theta)$, to estimate
$\bm\theta$:

. . .

Maximum-likelihood:
\begin{align*}
\begin{cases}
    \bm{\hat\theta}_{ML} = \argmax_{\bm{\theta}} \mathcal{L}(\bm{\theta}),\\
    \mathcal{L}(\bm{\theta}) = p(\bm{x} | \bm{\theta})
\end{cases}
\end{align*}

. . .

Maximum a posteriori:
\begin{align*}
\begin{cases}
    \bm{\hat\theta}_{MAP} = \argmax_{\bm{\theta}} p(\bm{\theta} | \bm{x}),\\
    p(\bm{\theta} | \bm{x}) = \frac{p(\bm{x} |\bm{\theta})p(\bm{\theta})}{p(\bm{x})}.
\end{cases}
\end{align*}

## Probabilistic Modelling: Inference

Given data, $\bm{x}$, and a model $p(\bm{x}, \bm{z})$, one is generally interested
in finding the posterior:

. . .

\begin{align*}
    p(\bm{z}|\bm{x}) &= \frac{p(\bm{x}|\bm{z})p(\bm{z})}{p(\bm{x})} \\
                     &= \frac{p(\bm{x}|\bm{z})p(\bm{z})}{\int p(\bm{x}|\bm{z'})p(\bm{z'}) d\bm{z'}}.
\end{align*}

. . .

In general, the integral in the denominator is intractable.
\onslide<4->

$\to$ Approximate inference is required.

# Variational Inference

## Variational Inference: Goal

Variational Inference is one way of dealing with the intractability previously
described.

. . .

Given a *variational* family $q(\bm{z} ; \bm\lambda)$,  find the parameters $\bm\lambda$
that minimze the Kullback-Leibler divergence between $q(\bm{z} ; \bm\lambda)$ and
$p(\bm{z}|\bm{x})$

## Variational Inference: ELBO

\begin{align*}
\onslide<1->{KL(q||p) &= \int q(\bm{z}) \log\frac{q(\bm{z})}{p(\bm{z})} d\bm{z} \\}
\onslide<2->{&= \int q(\bm{z}) (\log q(\bm{z}) - \log p(\bm{z}|\bm{x})) d\bm{z} \\}
\onslide<3->{&= \int q(\bm{z}) (\log q(\bm{z}) - (\log p(\bm{x}, \bm{z}) - \log p(\bm{x}))) d\bm{z} \\}
\onslide<4->{&= \mathbb{E}_q [\log q(\bm{z})] - \mathbb{E}_q [\log p(\bm{x}, \bm{z})] + \log p(\bm{x})}
\end{align*}

\onslide<5->
Which yields the lower bound (ELBO):
\begin{align*}
    ELBO(q) &= \mathbb{E}_q [\log p(\bm{x}, \bm{z})] - \mathbb{E}_q [\log q(\bm{z})] \\
            &= \mathbb{E}_q [\log p(\bm{x}|\bm{z})] + \mathbb{E}_q [\log p(\bm{z})] - \mathbb{E}_q [\log q(\bm{z})]
\end{align*}

# Normalizing Flows

## Normalizing Flows: Change of Variables

\onslide<1->{Given
\begin{align*}
\begin{cases}
    \bm{z} \sim p(\bm{z}) \\
    \bm{x} = g(\bm{z}; \bm\theta)
\end{cases}
\end{align*}}
\onslide<2->{then:
\begin{align*}
    f_X(\bm{x}) &= f_Z(g^{-1}(\bm{x};\bm\theta))\Big|\det\Big(\frac{d}{d\bm{x}}g^{-1}(\bm{x};\bm\theta)\Big)\Big| \\
    &= f_Z(g^{-1}(\bm{x};\bm\theta))\Big|\det\Big(\frac{d}{d\bm{z}}g(\bm{z};\bm\theta) \bigg{|}_{\bm{z} = g^{-1}(\bm{x};\bm\theta)}\Big)\Big|^{-1}
\end{align*}}

\onslide<3->{This can be optimize w.r.t. $\bm\theta$ so as to approximate
an arbitrary distribution}

## Normalizing Flows: Change of Variables

\onslide<1->{The above can be useful if}
\begin{itemize}
    \onslide<2->{\item The base density has a closed form expression and is easy to sample from}
    \onslide<3->{\item The determinant of the Jacobian of $g$ is computationally cheap - not the case, in general}
    \onslide<4->{\item The gradient of the determinant of the Jacobian of $g$ w.r.t $\bm\theta$ is computationally cheap}
\end{itemize}

## Normalizing Flows: Change of Variables

The framework of Normalizing Flows consists of composing several transformations
that fulfill the three listed conditions.

## Normalizing Flows: Affine Coupling Layer

An example of such a transformation is the Affine Coupling Layer \autocites{real-nvp}.

\onslide<1->{Splitting $\bm{z}$ into $(\bm{z_1}, \bm{z_2})$,}
\onslide<2->{\begin{align*}
    \begin{cases}
    \bm{x_1} &= \bm{z_1} \odot \exp\big(s(\bm{z_2})\big) + t(\bm{z_2}) \\
    \bm{x_2} &= \bm{z_2}.
    \end{cases}
\end{align*}}
\onslide<3->{This transformation has the following Jacobian matrix:
\begin{align*}
    J_{f(z)} =
        \begin{tikzpicture}[decoration=brace, baseline=-\the\dimexpr\fontdimen22\textfont2\relax ]
            \matrix (m) [matrix of math nodes,left delimiter=[,right delimiter={]}, ampersand replacement=\&] {
                \mbox{\Large$\frac{\partial \bm{x_1}}{\partial \bm{z_1}}$} \& \mbox{\Large$\frac{\partial \bm{x_1}}{\partial \bm{z_2}}$} \\
                \mbox{\Large$\frac{\partial \bm{x_2}}{\partial \bm{z_1}}$} \& \mbox{\Large$\frac{\partial \bm{x_2}}{\partial \bm{z_2}}$} \\
            };
        \end{tikzpicture}
    =
        \begin{tikzpicture}[decoration=brace, baseline=-\the\dimexpr\fontdimen22\textfont2\relax ]
            \matrix (m) [matrix of math nodes,left delimiter=[,right delimiter={]}, ampersand replacement=\&] {
                \mbox{diag}\Big(\exp\big(s(\bm{z_2})\big)\Big) \& \mbox{\Large$\frac{\partial \bm{x_1}}{\partial \bm{z_2}}$} \\
                \mbox{\Large$\bm{0}$} \& \mbox{\Large$I$} \\
            };
        \end{tikzpicture}
\end{align*}
}

# Variational Mixture of Normalizing Flows

## VMoNF: Motivation
\onslide<1->{How can we leverage the flexibility of normalizing flows, and endow it with
multimodal, discrete structure, like in a mixture model?}

\onslide<2->{Mixture of normalizing flows.}
\onslide<3->{
$\to$ Approximate inference is required.}

## VMoNF: Definition

Recall the ELBO:
\begin{align*}
    ELBO(q) &= \mathbb{E}_q [\log p(\bm{x}|\bm{z})] + \mathbb{E}_q [\log p(\bm{z})] - \mathbb{E}_q [\log q(\bm{z})]
\end{align*}

. . .

Let the variational posterior $q(z|x)$ be parameterized by a neural network. We
jointly optimize this objective, hence we learn the variational posterior and
the generative components simultaneously.

## VMoNF: Overview

\centering
\includegraphics[width=0.7\textwidth]{figures/train_overview.png}

## VMoNF: Experiments - Pinwheel (5 wings)

\centering
\includegraphics[width=0.475\textwidth]{figures/original_pinwheel.png}
\hfill
\includegraphics[width=0.475\textwidth]{figures/trained_pinwheel.png}

## VMoNF: Experiments - Pinwheel (3 wings)

\href{run:/home/colobas/dev/thesis/presentation/figures/animation/pinwheel.gif}{Trainining Animation}

## VMoNF: Experiments - 2 Circles

\centering
\includegraphics[width=0.475\textwidth]{figures/original_2_circles.png}
\hfill
\includegraphics[width=0.475\textwidth]{figures/trained_2_circles_2.png}

## VMoNF: Experiments - 2 Circles (semi supervised)

\centering
\includegraphics[width=0.475\textwidth]{figures/labeled_2_circles.png}
\hfill
\includegraphics[width=0.475\textwidth]{figures/trained_2_circles_semisup.png}

Note: 32 labeled points, 1024 unlabeled points

## VMoNF: Experiments - MNIST

\centering
\includegraphics[width=0.7\textwidth]{figures/trained_mnist.png}

# Conclusions

## Conclusions and Future Work

\begin{itemize}
    \onslide<1->{\item Similar work is being pursued and published in prominent venues: \autocites{RAD}{semisuplearning_nflows}}
    \onslide<2->{\item Formally describe the reasons why the model fails in cases like the 2 circles $\to$ Topology}
        \onslide<3->{\begin{itemize} \item Investigate the effect of a consistency loss regularization term \end{itemize}}
    \onslide<4->{\item Weight-sharing between components}
    \onslide<5->{\item Balance between complexities}
    \onslide<6->{\item (Controlled) component anihilation}
\end{itemize}

##

Thank you!

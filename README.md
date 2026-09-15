# Fitter V1

A responsive public marketplace prototype for finding trusted fitness coaches. The core journey is complete: homepage → coach search → search results → coach profile.

## Run locally

1. Install Node.js 20 or newer.
2. Run `npm install`.
3. Run `npm run dev` and open the address shown.

## Publish with Vercel

1. Create a free GitHub account and a new empty repository.
2. Upload this project (do not upload `node_modules` or `dist`).
3. Sign in to Vercel with GitHub and choose **Add New → Project**.
4. Import the Fitter repository. Vercel will detect Vite automatically.
5. Confirm build command `npm run build` and output directory `dist`, then choose **Deploy**.
6. Your temporary `*.vercel.app` address will be live in a minute or two.

## Connect a custom domain

1. In Vercel open the Fitter project, then **Settings → Domains**.
2. Enter the domain you own (for example `fitter.co.uk`) and choose **Add**.
3. At your domain registrar, add the DNS records Vercel displays. For `www`, this is normally a CNAME record; for the root domain, follow the exact A or ALIAS record Vercel gives you.
4. Return to Vercel and wait for the green verification state. HTTPS is issued automatically.

Every push to the GitHub repository will create a preview, and every push to the production branch will update the live website.

## Scope note

The current release uses realistic sample coach data and demonstrates the deployable public experience. Accounts, database persistence, messaging and real booking submission are intentionally the next product phase.

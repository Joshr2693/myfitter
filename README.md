# Fitter V1

A responsive marketplace for finding trusted fitness coaches. The current journey includes the homepage, coach search, profiles, booking and messaging demonstrations, client/coach dashboards, and Supabase-powered account registration and sign-in.

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

## Connect Supabase accounts

1. In Vercel add `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` for Production, Preview and Development, then redeploy.
2. In Supabase open **SQL Editor → New query**, paste the contents of `supabase/schema.sql`, and choose **Run**.
3. In Supabase open **Authentication → URL Configuration**. Set the site URL to your live domain and add the same domain followed by `/**` as a redirect URL.
4. Never put a Supabase secret or service-role key in Vercel under a `VITE_` name. The publishable key is the correct browser-safe key.

## Connect a custom domain

1. In Vercel open the Fitter project, then **Settings → Domains**.
2. Enter the domain you own (for example `fitter.co.uk`) and choose **Add**.
3. At your domain registrar, add the DNS records Vercel displays. For `www`, this is normally a CNAME record; for the root domain, follow the exact A or ALIAS record Vercel gives you.
4. Return to Vercel and wait for the green verification state. HTTPS is issued automatically.

Every push to the GitHub repository will create a preview, and every push to the production branch will update the live website.

## Scope note

Authentication and the secure initial database structure are ready. Coach listings, dashboard figures, messages and booking submission still use demonstration data while the next phase connects each screen to database records and adds administration/coach verification workflows.

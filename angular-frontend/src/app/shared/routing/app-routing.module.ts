import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

// All public routes
import { HomeComponent } from '../../components/home/home.component';
import { CreateComponent } from '../../components/create/create.component';
import { AboutComponent } from '../../components/about/about.component';
import { SignInComponent } from '../../components/sign-in/sign-in.component';
import { SignUpComponent } from '../../components/sign-up/sign-up.component';
import { VerifyEmailComponent } from '../../components/verify-email/verify-email.component';
import { ForgotPasswordComponent } from '../../components/forgot-password/forgot-password.component';
// All protected routes go here
import { AuthGuard } from "../../shared/guard/auth.guard";
import { SecureInnerPagesGuard } from "../guard/secure-inner-pages.guard";
import { ProfileComponent } from '../../components/profile/profile.component';


const routes: Routes = [
  { path: '', component: HomeComponent},
  { path: 'create/:artist_id', component: CreateComponent, pathMatch: 'full'},
  { path: 'about', component: AboutComponent},
  { path: 'sign-in', component: SignInComponent, canActivate: [SecureInnerPagesGuard]},
  { path: 'register', component: SignUpComponent, canActivate: [SecureInnerPagesGuard]},
  { path: 'profile', component: ProfileComponent, canActivate: [AuthGuard]},
  { path: 'forgot-password', component: ForgotPasswordComponent, canActivate: [SecureInnerPagesGuard]},
  { path: 'verify-email-address', component: VerifyEmailComponent, canActivate: [SecureInnerPagesGuard]},
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
import { Outlet } from 'react-router-dom';
import { ErrorBoundary } from '@/core/components';

export const AppLayout = () => {
  return (
    <ErrorBoundary>
      <div className="min-h-screen bg-gray-50 text-gray-900">
        <main>
          <Outlet />
        </main>
      </div>
    </ErrorBoundary>
  );
};
